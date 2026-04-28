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
from art import art
import argparse

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
parser.add_argument('-r', '--resolution', default=25, type=int, help='mice_num')
args = parser.parse_args()


mice_nums = args.num

for mice_num in mice_nums:
    resolution = args.resolution

    datapath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/origin/'
    savepath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/step1_ants/'
    pathlib.Path(savepath).mkdir(parents=True, exist_ok=True) 

    print(datapath)
    exit()


    print('\n######################   Step1 Ants   #######################')
    print('mice_num = '+str(mice_num))
    print('resolution = '+str(resolution)+'um\n')




    ############## Load Image  #############
    fixed = ants.image_read(datapath + 'pa_bg_' + str(resolution) +'um.nii.gz')
    moving = ants.image_read(datapath + 'Atlas_' + str(resolution) +'um.nii.gz')
    Annotation = ants.image_read(datapath + 'Annotation_' + str(resolution) +'um.nii.gz')
    print('loading finished')




    ############## Get Warp Field  #############
    T1 = time.time()
    formatted_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(T1))
    print("begin at ", formatted_time)
    mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='ElasticSyN', reg_iterations=(200, 100, 0), shrink_factors=(8,4,1))
    # mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='ElasticSyN', reg_iterations=(1000, 500, 0), shrink_factors=(8,4,1),verbose=True)
    shutil.copyfile(mytx['fwdtransforms'][1], savepath + 'atlas_to_pa_Generic_Affine_up.mat')
    shutil.copyfile(mytx['fwdtransforms'][0], savepath + 'atlas_to_pa_Warp.nii.gz')
    T2 = time.time()
    print('ANTS END :%ss \n' % ((T2 - T1)))





    ############## Transform   #############
    warped_Atlas = ants.apply_transforms(fixed=fixed, moving=moving, transformlist=mytx['fwdtransforms'],
                                        interpolator="linear")
    warped_Annotation = ants.apply_transforms(fixed=fixed, moving=Annotation, transformlist=mytx['fwdtransforms'],
                                        interpolator="nearestNeighbor")
    warped_Atlas = warped_Atlas.numpy()
    warped_Annotation = warped_Annotation.numpy()





    ############## Save DATA   #############
    print('Start Saving')
    savemat(savepath + 'ants_warped_atlas_' + str(resolution) +'um.mat',{'warped_Atlas': warped_Atlas})
    savemat(savepath + 'ants_warped_anno_' + str(resolution) +'um.mat',{'warped_Annotation': warped_Annotation})
    nib.Nifti1Image(warped_Atlas,np.eye(4)).to_filename(savepath + 'ants_warped_atlas_' + str(resolution) +'um.nii.gz')
    nib.Nifti1Image(warped_Annotation,np.eye(4)).to_filename(savepath + 'ants_warped_anno_' + str(resolution) +'um.nii.gz')
    print('Done!\n')

    os.remove(mytx['invtransforms'][1])
    os.remove(mytx['fwdtransforms'][0])
    print(art("shrug"))
    print('\n')