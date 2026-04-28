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
parser.add_argument('-r', '--resolution', default=25 ,type=int, help='mice_num')
parser.add_argument('-p', '--protein', default=0, type=int, help='mice_num')
args = parser.parse_args()


mice_nums = args.num
resolution = args.resolution
ifprotein = args.protein



for mice_num in mice_nums:
    datapath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/origin/'
    savepath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/traditional_ants/'
    pathlib.Path(savepath).mkdir(parents=True, exist_ok=True) 



    ############################### load image  ####################################
    print("\n####################### Traditionl ANTS of " + str(mice_num) + "#############################")
    print('mice_num = '+str(mice_num))
    print('resolution = '+str(resolution)+'um')

    fixed = ants.image_read(datapath + 'Atlas_' + str(resolution) +'um.nii.gz')
    fixed_anno = ants.image_read(datapath + 'Annotation_' + str(resolution) +'um.nii.gz')
    moving = ants.image_read(datapath + 'ims_data_' + str(resolution) +'um.nii.gz')

    # 填充图像
    # 计算需要填充的大小
    target_size = (480, 624, 336)
    fixed_size = fixed.shape
    print(fixed_size)
    padding_size = [target_size[i] - fixed_size[i] for i in range(len(target_size))]

    # 确保填充大小为正
    # 将填充大小转换为 pad_width 格式
    # 计算两侧填充的大小（居中填充）
    pad_width = [(padding_size[i] // 2, padding_size[i] - padding_size[i] // 2) for i in range(len(padding_size))]

    # 填充图像
    fixed = ants.pad_image(fixed, pad_width=pad_width)
    fixed_anno = ants.pad_image(fixed_anno, pad_width=pad_width)
    # fixed = fixed.numpy()
    # nib.Nifti1Image(fixed,np.eye(4)).to_filename(savepath + 'fixed_' + str(resolution) +'um_pad.nii.gz')
    print(fixed.shape)







    ############################### Get Warp Field ####################################
    T1 = time.time()
    mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='ElasticSyN', reg_iterations=(200, 100, 0), shrink_factors=(8,4,1),random_seed = 0)
    shutil.copyfile(mytx['fwdtransforms'][1], savepath + 'ims_to_atlas_Generic_Affine_up_pad.mat')
    shutil.copyfile(mytx['fwdtransforms'][0], savepath + 'ims_to_atlas_Warp_pad.nii.gz')
    shutil.copyfile(mytx['invtransforms'][0], savepath + 'ims_to_atlas_Generic_Affine_up_invtransforms_pad.mat')
    shutil.copyfile(mytx['invtransforms'][1], savepath + 'ims_to_atlas_Warp_invtransforms_pad.nii.gz')
    T2 = time.time()
    print('ANTS END :%ss' % ((T2 - T1)))



    ##########################   Transform  ##############################################
    warped_ims = ants.apply_transforms(fixed=fixed, moving=moving, transformlist=mytx['fwdtransforms'],
                                        interpolator="linear")

        
    warped_back_atlas = ants.apply_transforms(fixed=moving, moving=fixed, transformlist=mytx['invtransforms'],
                                            interpolator="linear")
    warped_back_anno = ants.apply_transforms(fixed=moving, moving=fixed_anno, transformlist=mytx['invtransforms'],
                                            interpolator="nearestNeighbor")

    warped_ims = warped_ims.numpy()
    warped_back_atlas = warped_back_atlas.numpy()
    warped_back_anno = warped_back_anno.numpy()




    ############################   Save DATA    #############################################
    print('Start Saving')
    savemat(savepath + 'ants_warped_ims_' + str(resolution) +'um_pad.mat',{'warped_ims': warped_ims})
    nib.Nifti1Image(warped_ims,np.eye(4)).to_filename(savepath + 'ants_warped_ims_' + str(resolution) +'um_pad.nii.gz')
    nib.Nifti1Image(warped_back_atlas,np.eye(4)).to_filename(savepath + 'ants_warped_back_atlas_' + str(resolution) +'um_pad.nii.gz')
    nib.Nifti1Image(warped_back_anno,np.eye(4)).to_filename(savepath + 'ants_warped_back_anno_' + str(resolution) +'um_pad.nii.gz')
    print('Done!\n')


    os.remove(mytx['invtransforms'][1])
    os.remove(mytx['fwdtransforms'][0])
    
    print(art("shrug"))
    print('\n')