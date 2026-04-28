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


current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('-n', '--num', type=int, help='mice_num')
parser.add_argument('-r', '--resolution', default=25, type=int, help='resolution')
parser.add_argument('-p', '--protein',default=0, type=int, help='protein') 
parser.add_argument('-s', '--step1',default='ants', type=str, help='step1') 
args = parser.parse_args()


mice_num = args.num
resolution = args.resolution
ifprotein = args.protein
method1 = args.step1

datapath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/origin/'
savepath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/traditional_ants/'
pathlib.Path(savepath).mkdir(parents=True, exist_ok=True) 


print('nice_num = '+str(mice_num))
print('resolution = '+str(resolution)+'um')


datapath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/origin/'
savepath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/traditional_ants/'
pathlib.Path(savepath).mkdir(parents=True, exist_ok=True) 


print('nice_num = '+str(mice_num))
print('resolution = '+str(resolution)+'um')

fixed = ants.image_read(datapath + 'Atlas_' + str(resolution) +'um.nii.gz')
moving = ants.image_read(datapath + 'ims_expert_anno_' + str(resolution) +'um_small.nii.gz')
moving_number = ants.image_read(datapath + 'ims_expert_anno_number_' + str(resolution) +'um_small.nii.gz')

print('loading finished')



# fixed_temp = ants.image_read(path_before_hd6+'/xxx/xxx\Data\2024\240828_align\270\ants')


T1 = time.time()
# mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='ElasticSyN', reg_iterations=(1, 0, 0), shrink_factors=(30,4,1))

print('trans begin')
# 定义一个新的字典 mytx
mytx = {}

# 将 'fwdtransforms' 键赋值为一个包含变换路径的列表
mytx['fwdtransforms'] = [
    savepath + 'ims_to_atlas_Warp.nii.gz',
    savepath + 'ims_to_atlas_Generic_Affine_up.mat'
]

mytx['invtransforms'] = [
    savepath + 'ims_to_atlas_Warp_invtransforms.nii.gz',
    savepath + 'ims_to_atlas_Generic_Affine_up_invtransforms.mat'
]

warped_ims_expert_anno = ants.apply_transforms(fixed=fixed, moving=moving, transformlist=mytx['fwdtransforms'],
                                     interpolator="nearestNeighbor")
warped_ims_expert_anno_number = ants.apply_transforms(fixed=fixed, moving=moving_number, transformlist=mytx['fwdtransforms'],
                                     interpolator="nearestNeighbor")


warped_ims_expert_anno.set_direction(fixed.direction)
warped_ims_expert_anno.set_origin(fixed.origin)
warped_ims_expert_anno.set_spacing(fixed.spacing)
warped_ims_expert_anno = warped_ims_expert_anno.numpy()

warped_ims_expert_anno_number.set_direction(fixed.direction)
warped_ims_expert_anno_number.set_origin(fixed.origin)
warped_ims_expert_anno_number.set_spacing(fixed.spacing)
warped_ims_expert_anno_number = warped_ims_expert_anno_number.numpy()



T2 = time.time()
print('程序运行时间:%s秒' % ((T2 - T1)))




savemat(savepath + 'ants_warped_ims_expert_anno_' + str(resolution) +'um_small.mat',{'warped_ims_expert_anno': warped_ims_expert_anno})
nib.Nifti1Image(warped_ims_expert_anno,np.eye(4)).to_filename(savepath + 'ants_warped_ims_expert_anno_' + str(resolution) +'um_small.nii.gz')






savemat(savepath + 'ants_warped_ims_expert_anno_number_' + str(resolution) +'um_small.mat',{'warped_ims_expert_anno_number': warped_ims_expert_anno_number})
nib.Nifti1Image(warped_ims_expert_anno_number,np.eye(4)).to_filename(savepath + 'ants_warped_ims_expert_anno_number_' + str(resolution) +'um_small.nii.gz')


