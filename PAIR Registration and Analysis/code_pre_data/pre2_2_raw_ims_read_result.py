import os
import numpy as np
import nibabel as nib
from scipy.io import loadmat, savemat
from scipy.ndimage import zoom
from skimage.io import imread
import glob


current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]


# Parameters
mice_nums = [13]
reg_resolution = 25
x_resolution = 1.75
y_resolution = 1.75
z_resolution = 50

print(mice_nums)

print("ATTENTION: Please change the mice num in the pyfile")

for mice_num in mice_nums:

    ######################  Read tif to RAW mat    #################################
    rootpath = f'{path_before_hd6}/xxx/xxx/Data/2024/240926_align/{mice_num}/'
    origin_path = f'{rootpath}{reg_resolution}um/origin/'
    ims_data_path = f'{rootpath}/ims_result/'
    os.makedirs(origin_path, exist_ok=True)
    ims_data_file = os.path.join(origin_path, 'ims_data_result.mat')
    
    if os.path.exists(ims_data_file):
        data = loadmat(ims_data_file)
        ims_data = data['ims_data_result']
    else:
        # Load image data from directory
        image_files = sorted(glob.glob(os.path.join(ims_data_path, '*.tif')))
        sample_image = imread(image_files[0])
        yy, xx = sample_image.shape
        zz = len(image_files)
        
        ims_data = np.zeros((xx, yy, zz), dtype=sample_image.dtype)
        
        for i, file in enumerate(image_files):
            ims_data[:, :, i] = imread(file).T
            if (i + 1) % 100 == 0:
                print(f"Loaded {i + 1}/{zz} images.")
        savemat(ims_data_file, {'ims_data_result': ims_data})



    ######################  Zoom to new Resolution    #################################
    print('Start zoom for ' + str(mice_num))
    ims_data2 = zoom(ims_data, (x_resolution / reg_resolution, y_resolution / reg_resolution, z_resolution / reg_resolution), order=1)

    # Sort the shape and get the indices for sorting
    t1 = np.sort(np.shape(ims_data2))
    t2 = np.argsort(np.shape(ims_data2))
    t4 = [t2[1], t2[2], t2[0]]

    print(ims_data2.shape)
    ims_data3 = np.transpose(ims_data2, axes=t4)
    ims_data3 = np.flip(ims_data3, axis=2)
    if mice_num == 310:
        ims_data3 = np.flip(ims_data3, axis=1)
    print(ims_data3.shape)


    ######################      Save       #################################
    savemat(os.path.join(origin_path, f'ims_data_result_{reg_resolution}um.mat'), {'ims_data3': ims_data3})
    nii_img = nib.Nifti1Image(ims_data3, affine=np.eye(4))
    nib.save(nii_img, os.path.join(origin_path, f'ims_data_result_{reg_resolution}um.nii.gz'))
    print(f"Processed data for mouse {mice_num} saved.\n")





from art import art
print(art("shrug"))