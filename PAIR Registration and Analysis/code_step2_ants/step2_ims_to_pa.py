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
import argparse
from art import art

current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument(
    '-n',
    "--num",
    nargs="+",  # "+" 表示至少一个值
    type=int,   # 转换为整数
    help="List of mice_num"
)
parser.add_argument('-r', '--resolution', default=25, type=int, help='resolution')
parser.add_argument('-p', '--protein',default=0, type=int, help='protein') 
parser.add_argument('-s', '--step1',default='ants', type=str, help='step1') 
args = parser.parse_args()


mice_nums = args.num
resolution = args.resolution
ifprotein = args.protein
method1 = args.step1


for mice_num in mice_nums:

    datapath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/origin/'
    savepath2 = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/step2_' + method1 + '_ants/'
    pathlib.Path(savepath2).mkdir(parents=True, exist_ok=True) 



    print('######################   Step2 of  '+ method1 + '-ants  TO PA #######################')
    print('mice_num = '+str(mice_num))
    print('resolution = '+str(resolution)+'um')
    print('method1 = '+ method1 +'\n')



    ############## Load Image  #############
    fixed = ants.image_read(datapath + 'pa_bg_' + str(resolution) +'um.nii.gz')
    moving = ants.image_read(datapath + 'ims_data_' + str(resolution) +'um.nii.gz')
    if ifprotein:
        result =  ants.image_read(datapath + 'ims_data_result_' + str(resolution) +'um.nii.gz')
    print('loading finished')



    ############## Get Warp Field  #############
    T1 = time.time()
    mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='ElasticSyN', reg_iterations=(200, 100, 0), shrink_factors=(8,4,1),random_seed = 0)
    shutil.copyfile(mytx['fwdtransforms'][1], savepath2 + 'ims_to_'+method1+'_warped_atlas_Generic_Affine_up_PA.mat')
    shutil.copyfile(mytx['fwdtransforms'][0], savepath2 + 'ims_to_'+method1+'_warped_atlas_Warp_PA.nii.gz')
    shutil.copyfile(mytx['invtransforms'][0], savepath2 + 'ims_to_'+method1+'_warped_atlas_Generic_Affine_up_invtransforms_PA.mat')
    shutil.copyfile(mytx['invtransforms'][1], savepath2 + 'ims_to_'+method1+'_warped_atlas_Warp_invtransforms_PA.nii.gz')
    T2 = time.time()
    print('ANTS END :%ss' % ((T2 - T1)))




    ############## Transform   #############
    warped_ims = ants.apply_transforms(fixed=fixed, moving=moving, transformlist=mytx['fwdtransforms'],
                                        interpolator="linear")
    if ifprotein:
        warped_ims_result = ants.apply_transforms(fixed=fixed, moving=result, transformlist=mytx['fwdtransforms'],
                                        interpolator="linear")
    warped_ims = warped_ims.numpy()
    if ifprotein:
        warped_ims_result = warped_ims_result.numpy()




    ############## Save Data  #############
    print('Start Saving')
    savemat(savepath2 + method1 +'_ants_warped_ims_' + str(resolution) +'um_PA.mat',{'warped_ims': warped_ims})
    nib.Nifti1Image(warped_ims,np.eye(4)).to_filename(savepath2 +  method1 +'_ants_warped_ims_' + str(resolution) +'um_PA.nii.gz')

    if ifprotein:
        savemat(savepath2 + method1 +'_ants_warped_ims_result_' + str(resolution) +'um_PA.mat',{'warped_ims_result': warped_ims_result})
        nib.Nifti1Image(warped_ims_result,np.eye(4)).to_filename(savepath2 +  method1 +'_ants_warped_ims_result_' + str(resolution) +'um_PA.nii.gz')


    print('Done!\n')

    os.remove(mytx['invtransforms'][1])
    os.remove(mytx['fwdtransforms'][0])
    print(art("shrug"))
    print('\n')