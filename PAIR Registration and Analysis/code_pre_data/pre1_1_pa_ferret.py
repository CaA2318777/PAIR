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


user_input = input("/nWarning! /n是否要重新提取 "+str(mice_num)+" 数据？/n注意这样之前的ANTS所有配准将失效！(Y/N): ")
if user_input.strip().lower() != 'y':
    print('Exit/n')
    exit()


print('####################### PA PRE  '+str(mice_num) + '###################')
print('mice_num = '+str(mice_num))
print('resolution = '+str(resolution)+'um/n')


current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]


#%%################################     SAVE NII    #################################################
# SAVE NII
datapath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'


mat_data = loadmat(datapath+'mask_cut.mat')
mask = mat_data['mask']
mask = np.transpose(mask,(2,0,1))
mask = np.flip(mask,axis=0)
mask = np.flip(mask,axis=1)


mat_data = loadmat(datapath+'recondata_cut_mc_bgb_unsmooth.mat')
pa_raw = mat_data['recondata_cut_mc_bgb']
pa_raw = np.transpose(pa_raw,(2,0,1))
pa_raw = np.flip(pa_raw,axis=0)
pa_raw = np.flip(pa_raw,axis=1)
pa_raw = pa_raw*mask - (1-mask)*255 - (1-mask)*255 - (1-mask)*255 - (1-mask)*255

mat_data = loadmat(datapath+'recondata.mat')
pa_raw2 = mat_data['recondata']
pa_raw2 = np.transpose(pa_raw2,(2,0,1))
pa_raw2 = np.flip(pa_raw2,axis=0)
pa_raw2 = np.flip(pa_raw2,axis=1)
pa_raw2 = pa_raw2*mask

nib.Nifti1Image(pa_raw2,np.eye(4)).to_filename(datapath + 'recondata.nii.gz')
nib.Nifti1Image(pa_raw,np.eye(4)).to_filename(datapath + 'recondata_cut_bgb_unsmooth.nii.gz')
nib.Nifti1Image(mask,np.eye(4)).to_filename(datapath + 'mask.nii.gz')

if ifprotein:
    mat_data = loadmat(datapath+'res_ad_das1_reg1_0.9.mat')
    res_ad = mat_data['res_ad']
    res_ad = np.transpose(res_ad,(2,0,1))
    res_ad = np.flip(res_ad,axis=0)
    res_ad = np.flip(res_ad,axis=1)
    nib.Nifti1Image(res_ad,np.eye(4)).to_filename(datapath + 'res_ad.nii.gz')

print('/nSave '+str(mice_num)+' recondata to nii/n')



#%% ################################   ANTS Rigid ####################################
# ANTS Rigid


# os.environ["ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS"] = "1"
fixed = ants.image_read(path_before_hd6 + '/xxx/xxx/HD1/atlas_ferret_dataset/evDTI_template_TR.nii.gz')
moving = ants.image_read(datapath + 'recondata.nii.gz')
moving_real =  ants.image_read(datapath + 'recondata_cut_bgb_unsmooth.nii.gz')
print('Load Ants Rigid Data Finish')


if not os.path.exists(datapath + 'pa_rigid_Generic_Affine.mat'):

    print('/nUsing My own Rigid')
    T1 = time.time()
    formatted_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(T1))
    print("ANTS begin at ", formatted_time)
    mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='Rigid',random_seed=0)
    shutil.copyfile(mytx['fwdtransforms'][0], datapath + 'pa_rigid_Generic_Affine.mat')
    T2 = time.time()
    print('Rigid Time: %ss' % ((T2 - T1)))

    rigid_transform = ants.read_transform(datapath + 'pa_rigid_Generic_Affine.mat')
    parameters = rigid_transform.parameters
    parameters[9] = rigid_transform.parameters[9] + 256
    parameters[10] = rigid_transform.parameters[10] + 256
    rigid_transform.set_parameters(parameters)
    ants.write_transform(rigid_transform, path_before_hd6 + '/xxx/xxx/Data/2024/241113_final_brains/affine_mat/'+str(mice_num)+'_rigid_affine.mat')




# rigid_transform = ants.read_transform(path_before_hd6 + '/xxx/xxx/Data/2024/241113_final_brains/affine_mat/'+str(mice_num)+'_rigid_affine.mat')
# parameters = rigid_transform.parameters
# parameters[9] = rigid_transform.parameters[9] - 256
# parameters[10] = rigid_transform.parameters[10] - 256
# rigid_transform.set_parameters(parameters)
# ants.write_transform(rigid_transform, datapath + 'pa_rigid_Generic_Affine_jcy.mat')


mytx = {}
mytx['fwdtransforms'] = [] # 初始化为空列表
mytx['fwdtransforms'].append(datapath + 'pa_rigid_Generic_Affine.mat')
warped_pa = ants.apply_transforms(fixed=fixed, moving=moving_real, transformlist=mytx['fwdtransforms'],
                                  interpolator="linear")



warped_pa_75 = warped_pa.numpy()


nib.Nifti1Image(warped_pa_75,np.eye(4)).to_filename(datapath + 'pa_bg_75um.nii.gz')





#%%  #######################  ZOOM to high resolution ###########################      
print('/n Start Zoom to ' + str(resolution) + 'um')
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


