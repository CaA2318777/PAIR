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
import argparse

def warp_image_3d(image, warp_field):
    depth, height, width = image.shape
    coordinates = np.meshgrid(np.arange(depth), np.arange(height), np.arange(width), indexing='ij')
    coordinates = np.array(coordinates)

    # Add the warp field displacements to the original coordinates
    new_coords = coordinates + warp_field.transpose(3, 0, 1, 2)
    new_coords = new_coords.reshape(3, -1)

    # Warp the image using map_coordinates
    # warped_image = map_coordinates(image, new_coords, order=0, mode='nearest')
    warped_image = map_coordinates(image, new_coords, order=0, mode='constant', cval=0)
    return warped_image.reshape(depth, height, width)

def warp_image_3d(image, warp_field):
    depth, height, width = image.shape
    coordinates = np.meshgrid(np.arange(depth), np.arange(height), np.arange(width), indexing='ij')
    coordinates = np.array(coordinates)

    # Add the warp field displacements to the original coordinates
    new_coords = coordinates + warp_field.transpose(3, 0, 1, 2)
    new_coords = new_coords.reshape(3, -1)

    # Warp the image using map_coordinates
    warped_image = map_coordinates(image, new_coords, order=0, mode='constant', cval=0)
    return warped_image.reshape(depth, height, width)

# def warp_image_3d_linear(image, warp_field):
#     depth, height, width = image.shape
#     coordinates = np.meshgrid(np.arange(depth), np.arange(height), np.arange(width), indexing='ij')
#     coordinates = np.array(coordinates)

#     # Add the warp field displacements to the original coordinates
#     new_coords = coordinates + warp_field.transpose(3, 0, 1, 2)
#     new_coords = new_coords.reshape(3, -1)

#     # Warp the image using map_coordinates
#     # warped_image = map_coordinates(image, new_coords, order=1, mode='nearest')
#     warped_image = map_coordinates(image, new_coords, order=1, mode='constant', cval=0)
#     return warped_image.reshape(depth, height, width)



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
import pathlib
def main():

    current_file_path = os.path.abspath(__file__)
    path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]

    parser = argparse.ArgumentParser(description='Get resolution and mouse_num.')
    parser.add_argument('-r',default=25, type=int, required=False, help='The value of resolution.')
    parser.add_argument(
        '-n',
        "--num",
        nargs="+",  # "+" 表示至少一个值
        type=int,   # 转换为整数
        help="List of mice_num"
    )
    args = parser.parse_args()

    mice_nums = args.num
    resolution = 25 

    for mice_num in mice_nums:
        datapath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/'+str(mice_num)+'/'+ str(resolution)+'um/'
        raw_path = path_before_hd6 + '/xxx/xxx/Data/2024/241113_final_brains/'+str(mice_num)+'/'+ str(resolution)+'um/step1_vm/'

        print(datapath)
        pathlib.Path(datapath+ 'step1_vm/').mkdir(parents=True, exist_ok=True) 

        pa_raw_25 = nib.load(raw_path+ '/aligned_pa_25_cut_'+str(mice_num)+'.nii')
        pa_raw_25 =  np.asarray(pa_raw_25.dataobj)
        shift = 3
        shifted_matrix = np.zeros_like(pa_raw_25)
        shifted_matrix[shift:, shift:,:] = pa_raw_25[:-shift, :-shift, :]
        pa_raw_25 = shifted_matrix
        affine = np.eye(4)
        nifti_img = nib.Nifti1Image(pa_raw_25, affine)
        # nib.save(nifti_img, datapath+ 'step1_vm/raw_pa_25.nii.gz')


        warp_field_75 = nib.load(raw_path+ '/model_instance_specific_optimized_predicted_atlas_warpfield_'+str(mice_num)+'.nii')
        warp_field_75 = np.asarray(warp_field_75.dataobj).transpose(1,2,3,0)


        
        atlas_25 = nib.load(raw_path+ '/atlas_25_'+str(mice_num)+'.nii')
        atlas_25 =  np.asarray(atlas_25.dataobj)
        anno_25 = nib.load(raw_path+ '/annotation_25_'+str(mice_num)+'.nii')
        anno_25 =  np.asarray(anno_25.dataobj)


        
        
        # pa_75 =  nib.load(raw_path+ '/normalized_pa_'+str(mice_num)+'.nii')
        # pa_75 =  np.asarray(pa_75.dataobj)
        # pa_75_up =  zoom(pa_75, zoom=(3, 3, 3), order=1)  # Linear interpolation
        # affine = np.eye(4)
        # nifti_img = nib.Nifti1Image(pa_75_up, affine)
        # nib.save(nifti_img, datapath+ 'step1_vm/pa_75_up.nii.gz')

        print("---------------------load finished----------------------")

        atlas_75 = zoom(atlas_25, zoom=(1/3, 1/3, 1/3), order=1)  # Linear interpolation
        # affine = np.eye(4)
        # nifti_img = nib.Nifti1Image(atlas_25, affine)
        # nib.save(nifti_img, datapath+ 'step1_vm/raw_atlas_25.nii.gz')

        # plot_slices(atlas_25,'25')
        # plot_slices(atlas_75,'75')
        

        final_image_75 = warp_image_3d(atlas_75, warp_field_75)
        affine = np.eye(4)
        nifti_img = nib.Nifti1Image(final_image_75, affine)
        # nib.save(nifti_img, datapath+ 'step1_vm/vm_warped_atlas_75.nii.gz')

        final_75_up = zoom(final_image_75, zoom=(3, 3, 3), order=1) 
        affine = np.eye(4)
        nifti_img = nib.Nifti1Image(final_75_up, affine)
        # nib.save(nifti_img, datapath+ 'step1_vm/vm_warped_atlas_75_up25.nii.gz')


        # plot_slices(final_image_75,'f75up')

        print("------------------start zoom field-----------------------------")
        import time
        T1 = time.time()
        upsample_factor = 3
        warp_field_25 = zoom(warp_field_75, zoom=(upsample_factor, upsample_factor, upsample_factor, 1), order=2)  # Linear interpolation
        warp_field_25 = warp_field_25*3
        print("finish zoom")
        T2 = time.time()
        print(T2-T1)

        final_image_25 = warp_image_3d(atlas_25, warp_field_25)
        # plot_slices(final_image_25,'f25')

        final_anno_25 = warp_image_3d(anno_25, warp_field_25)
        # plot_slices(final_anno_25,'fanno25')

        shift = 3
        shifted_matrix = np.zeros_like(final_image_25)
        shifted_matrix[shift:, shift:,:] = final_image_25[:-shift, :-shift, :]
        final_image_25 = shifted_matrix

        shift = 3
        shifted_matrix = np.zeros_like(final_anno_25)
        shifted_matrix[shift:, shift:, :] = final_anno_25[:-shift, :-shift, :]
        final_anno_25 = shifted_matrix

        print('start saving')
        affine = np.eye(4)
        nifti_img = nib.Nifti1Image(final_image_25, affine)
        nib.save(nifti_img, datapath+ 'step1_vm/vm_warped_atlas_25um_specific.nii.gz')
        # savemat(datapath+ 'step1_vm/vm_warped_atlas_25um_unmask.mat',{'warped_Atlas': final_image_25})

        
        affine = np.eye(4)
        nifti_img = nib.Nifti1Image(final_anno_25, affine)
        nib.save(nifti_img, datapath+ 'step1_vm/vm_warped_anno_25um_specific.nii.gz')
        # savemat(datapath+ 'step1_vm/vm_warped_anno_25um_unmask.mat',{'warped_Annotation': final_anno_25})


        aaa  =1 

if __name__ == '__main__':
    main()


