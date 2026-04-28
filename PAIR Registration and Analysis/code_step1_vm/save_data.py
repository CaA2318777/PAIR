import numpy as np
from scipy.ndimage import map_coordinates
import matplotlib.pyplot as plt
import nibabel as nib
import argparse
import re
import numpy as np
import scipy.io as io
from scipy.io import savemat
from scipy.ndimage import zoom


def warp_image_3d(image, warp_field):
    depth, height, width = image.shape
    coordinates = np.meshgrid(np.arange(depth), np.arange(height), np.arange(width), indexing='ij')
    coordinates = np.array(coordinates)

    # Add the warp field displacements to the original coordinates
    new_coords = coordinates + warp_field.transpose(3, 0, 1, 2)
    new_coords = new_coords.reshape(3, -1)

    # Warp the image using map_coordinates
    warped_image = map_coordinates(image, new_coords, order=0, mode='nearest')
    return warped_image.reshape(depth, height, width)


def format_number(num):
    # 将数字转换为字符串，保留两位小数
    str_num = f"{num:.2f}"
    # 使用正则表达式去除不必要的小数位
    str_num = re.sub(r'\.?0+$', '', str_num)
    return str_num

def plot_slices(image, title=''):
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    mid_slices = [s // 2 for s in image.shape]
    axes[0].imshow(image[mid_slices[0], :, :], cmap='gray')
    axes[0].set_title(f'{title} - Axial Slice')
    axes[1].imshow(image[:, mid_slices[1], :], cmap='gray')
    axes[1].set_title(f'{title} - Coronal Slice')
    axes[2].imshow(image[:, :, mid_slices[2]], cmap='gray')
    axes[2].set_title(f'{title} - Sagittal Slice')
    plt.show()


import os



def main():
   
    # parser = argparse.ArgumentParser(description='Get resolution and mouse_num.')
    # parser.add_argument('-r', type=int, required=True, help='The value of resolution.')
    # parser.add_argument('-num', type=float, required=True, help='The value of num.')
    # args = parser.parse_args()


    mice_num = 270
    resolution = 25
    datapath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/'+format_number(mice_num)+'/'+ str(resolution)+'um/'

    raw_path = path_before_hd6 + '/xxx/jcy/'+format_number(mice_num)+'/'

    warp_field_75 = nib.load(raw_path+ 'new_model_optimized_atlas_warpfield_'+format_number(mice_num)+'.nii')
    warp_field_75 = np.asarray(warp_field_75.dataobj).transpose(1,2,3,0)



    atlas_25 = nib.load(raw_path+ 'not_cropped_upsampled_atlas_'+format_number(mice_num)+'.nii')
    atlas_25 =  np.asarray(atlas_25.dataobj)
    anno_25 = nib.load(raw_path+ 'not_cropped_upsampled_atlas_annotation_'+format_number(mice_num)+'.nii')
    anno_25 =  np.asarray(anno_25.dataobj)
    
    # pa_75 =  nib.load(datapath+ 'step1_vm/normalized_pa_'+format_number(mice_num)+'.nii')
    # pa_75 =  np.asarray(pa_75.dataobj)
    # pa_75_up =  zoom(pa_75, zoom=(3, 3, 3), order=1)  # Linear interpolation
    # affine = np.eye(4)
    # nifti_img = nib.Nifti1Image(pa_75_up, affine)
    # nib.save(nifti_img, datapath+ 'step1_vm/pa_75_up.nii.gz')

    print("---------------------load finished----------------------")

    # Define the cropping region
   
    xstart,xend = 49*3,209*3
    ystart,yend = 20*3,228*3
    zstart, zend = 74*3,186*3


    # xstart,xend = 47*3,207*3
    # ystart,yend = 30*3,238*3
    # zstart, zend = 102*3,214*3


    # Crop the image data
    atlas_25 = atlas_25[xstart:xend, ystart:yend, zstart:zend]
    atlas_75 = zoom(atlas_25, zoom=(1/3, 1/3, 1/3), order=1)  # Linear interpolation
    anno_25 = anno_25[xstart:xend, ystart:yend, zstart:zend]


    affine = np.eye(4)
    nifti_img = nib.Nifti1Image(atlas_25, affine)
    nib.save(nifti_img, datapath+ 'step1_vm/atlas_25.nii.gz')

    plot_slices(atlas_25,'25')
    plot_slices(atlas_75,'75')
    

    final_image_75 = warp_image_3d(atlas_75, warp_field_75)
    affine = np.eye(4)
    nifti_img = nib.Nifti1Image(final_image_75, affine)
    nib.save(nifti_img, datapath+ 'step1_vm/vm_warped_atlas_75.nii.gz')
    final_75_up = zoom(final_image_75, zoom=(3, 3, 3), order=1) 
    affine = np.eye(4)
    nifti_img = nib.Nifti1Image(final_75_up, affine)
    nib.save(nifti_img, datapath+ 'step1_vm/final_75_up.nii.gz')
    plot_slices(final_image_75,'f75')

    print("start zoom")
    upsample_factor = 3
    warp_field_25 = zoom(warp_field_75, zoom=(upsample_factor, upsample_factor, upsample_factor, 1), order=1)  # Linear interpolation
    warp_field_25 = warp_field_25*3
    print("finish zoom")

    final_image_25 = warp_image_3d(atlas_25, warp_field_25)
    plot_slices(final_image_25,'f25')

    final_anno_25 = warp_image_3d(anno_25, warp_field_25)
    plot_slices(final_anno_25,'fanno25')

    affine = np.eye(4)
    nifti_img = nib.Nifti1Image(final_image_25, affine)
    nib.save(nifti_img, datapath+ 'step1_vm/vm_warped_atlas_25um_unmask.nii.gz')
    savemat(datapath+ 'step1_vm/vm_warped_atlas_25um_unmask.mat',{'warped_Atlas': final_image_25})

    
    affine = np.eye(4)
    nifti_img = nib.Nifti1Image(final_anno_25, affine)
    nib.save(nifti_img, datapath+ 'step1_vm/vm_warped_anno_25um_unmask.nii.gz')
    savemat(datapath+ 'step1_vm/vm_warped_anno_25um_unmask.mat',{'warped_Annotation': final_anno_25})


    aaa  =1 

if __name__ == '__main__':
    main()


