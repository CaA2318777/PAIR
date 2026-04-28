import ants
import numpy as np
import time
import nibabel as nib
import scipy.io as io
from scipy.io import savemat
import pathlib
import os
import shutil
import json
from scipy.io import loadmat
import argparse
from scipy.ndimage import zoom

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('-n', '--num', type=int, help='mice_num')
parser.add_argument('-r', '--resolution',default=25, type=int, help='mice_num') 
parser.add_argument('-p', '--protein',default=False, type=int, help='mice_num') 
args = parser.parse_args()


mice_num = args.num
resolution = args.resolution
ifprotein = args.protein



print('####################### PA PRE  '+str(mice_num) + '###################')
print('mice_num = '+str(mice_num))
print('resolution = '+str(resolution)+'um\n')

import os
current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]


#######################  ZOOM to high resolution ########################### 
# SAVE NII
datapath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'
      
print('\n Start Zoom to ' + str(resolution) + 'um')
upsample_factor = 75/resolution
savepath = datapath + '/' + str(resolution) + 'um/origin/'
pathlib.Path(savepath).mkdir(parents=True, exist_ok=True) 

warped_pa_75 = ants.image_read(datapath + 'pa_bg_75um.nii.gz')
warped_pa_75 = warped_pa_75.numpy()
warped_pa_upsample = zoom(warped_pa_75, zoom=(upsample_factor, upsample_factor, upsample_factor), order=1) 
nib.Nifti1Image(warped_pa_upsample,np.eye(4)).to_filename(savepath + 'pa_bg_'+str(resolution)+'um.nii.gz')


if ifprotein:
    warped_res_ad = ants.image_read(datapath + 'res_ad_75um.nii.gz')
    warped_res_ad = warped_res_ad.numpy()
    warped_res_ad_upsample = zoom(warped_res_ad, zoom=(upsample_factor, upsample_factor, upsample_factor), order=1) 
    nib.Nifti1Image(warped_res_ad_upsample,np.eye(4)).to_filename(savepath + 'res_ad_'+str(resolution)+'um.nii.gz')



from art import art
print(art("shrug"))

