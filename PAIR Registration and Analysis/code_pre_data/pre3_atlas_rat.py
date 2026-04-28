import os
import numpy as np
import nibabel as nib
from scipy.io import savemat
from scipy.ndimage import zoom
import argparse

current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]

# Parameters
parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('-n', '--num', type=int, help='mice_num')
parser.add_argument('-r', '--resolution',default=39, type=int, help='mice_num') 
parser.add_argument('-c', '--cutstart',default=0, type=int, help='mice_num') 
args = parser.parse_args()


mice_num = args.num
resolution = args.resolution
cutstart = args.cutstart


rootpath = f'{path_before_hd6}/xxx/xxx/Data/2024/240926_align/{mice_num}/'
origin_path = os.path.join(rootpath, f'{resolution}um/origin/')
os.makedirs(origin_path, exist_ok=True)


########################### load image  ###########################
print(str(mice_num) + ' '+str(resolution)+'um')
atlas_path = f'{path_before_hd6}/xxx/xxx/HD1/atlas_rat_dataset/atlas.nii.gz'
annotation_path = f'{path_before_hd6}/xxx/xxx/HD1/atlas_rat_dataset/annotation.nii.gz'
Atlas = nib.load(atlas_path).get_fdata()
Annotation = nib.load(annotation_path).get_fdata()
Atlas = Atlas.astype(np.float64)
Annotation = Annotation.astype(np.float64)


########################### Cut IMAGE ###########################
if cutstart>0:
    print('No Need to Cut Atlas')
    Atlas[:, :cutstart, :] = 0
    Annotation[:, :cutstart, :] = 0

print("Atlas shape:", Atlas.shape)



########################### Resize if resolution is not 39 ###########################
if resolution != 39:
    scale_factor = 39 / resolution
    Atlas = zoom(Atlas, scale_factor, order=1)  # Linear interpolation
    Annotation = zoom(Annotation, scale_factor, order=0)  # Nearest-neighbor interpolation for annotation


############################ Save the resized data ###########################
savemat(os.path.join(origin_path, f'Atlas_{resolution}um.mat'), {'Atlas': Atlas.astype(np.uint16)})
savemat(os.path.join(origin_path, f'Annotation_{resolution}um.mat'), {'Annotation': Annotation.astype(np.uint16)})

atlas_nii = nib.Nifti1Image(Atlas, affine=np.eye(4))
annotation_nii = nib.Nifti1Image(Annotation, affine=np.eye(4))
nib.save(atlas_nii, os.path.join(origin_path, f'Atlas_{resolution}um.nii.gz'))
nib.save(annotation_nii, os.path.join(origin_path, f'Annotation_{resolution}um.nii.gz'))

print("Processing complete. Files saved.")



from art import art
print(art("shrug"))