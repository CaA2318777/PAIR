import os
import numpy as np
import nibabel as nib
from scipy.io import loadmat, savemat
from scipy.ndimage import zoom
from skimage.io import imread
import glob
import argparse

current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]

# Parameters
parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('-n', '--num', type=int, help='mice_num')
parser.add_argument('-r', '--resolution',default=25, type=int, help='mice_num') 
parser.add_argument('-c', '--cutstart',default=0, type=int, help='mice_num') 
args = parser.parse_args()


mice_num = args.num
resolution = args.resolution
cutstart = args.cutstart

rootpath = f'{path_before_hd6}/xxx/xxx/Data/2024/240926_align/{mice_num}/'
origin_path = f'{rootpath}{resolution}um/origin/'
os.makedirs(origin_path, exist_ok=True)


# Check if ims_data.mat exists
if os.path.exists(os.path.join(origin_path, 'ims_cutstart.mat')):
    print('Cut already Done')
    exit()
    
ims_data_file_path =  nib.load(os.path.join(origin_path, 'ims_data_25um.nii.gz'))
ims_data3 = np.asarray(ims_data_file_path.dataobj)
print(ims_data3.shape)
ims_data3[:,:cutstart,:] = 0


savemat(os.path.join(origin_path, 'ims_cutstart.mat'), {'cutstart': cutstart})
nii_img = nib.Nifti1Image(ims_data3, affine=np.eye(4))
nib.save(nii_img, os.path.join(origin_path, f'ims_data_{resolution}um.nii.gz'))
print(f"Processed data for mouse {mice_num} saved.\n")


from art import art
print(art("shrug"))