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

fixed = ants.image_read(datapath + 'ims_data_' + str(resolution) +'um.nii.gz')
moving = ants.image_read(datapath + 'Atlas_' + str(resolution) +'um.nii.gz')
Annotation = ants.image_read(datapath + 'Annotation_' + str(resolution) +'um.nii.gz')

print('loading finished')

T1 = time.time()
mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='ElasticSyN', reg_iterations=(120, 60, 0))
warped_Atlas = ants.apply_transforms(fixed=fixed, moving=moving, transformlist=mytx['fwdtransforms'],
                                     interpolator="linear")
warped_Annotation = ants.apply_transforms(fixed=fixed, moving=Annotation, transformlist=mytx['fwdtransforms'],
                                     interpolator="nearestNeighbor")






warped_Annotation.set_direction(fixed.direction)
warped_Annotation.set_origin(fixed.origin)
warped_Annotation.set_spacing(fixed.spacing)

warped_Atlas.set_direction(fixed.direction)
warped_Atlas.set_origin(fixed.origin)
warped_Atlas.set_spacing(fixed.spacing)


warped_Atlas = warped_Atlas.numpy()
warped_Annotation = warped_Annotation.numpy()





fwd_list = mytx['fwdtransforms']
inv_list = mytx['invtransforms']


# Warp = ants.image_read(fwd_list[0]).numpy()
# Generic_Affine = io.loadmat(fwd_list[1])
# Inverse_Warp = ants.image_read(inv_list[1]).numpy()



T2 = time.time()
print('程序运行时间:%s秒' % ((T2 - T1)))




savemat(savepath + 'ants_warped_atlas_' + str(resolution) +'um.mat',{'warped_Atlas': warped_Atlas})
nib.Nifti1Image(warped_Atlas,np.eye(4)).to_filename(savepath + 'ants_warped_atlas_' + str(resolution) +'um.nii.gz')




savemat(savepath + 'ants_warped_anno_' + str(resolution) +'um.mat',{'warped_Annotation': warped_Annotation})
nib.Nifti1Image(warped_Annotation,np.eye(4)).to_filename(savepath + 'ants_warped_anno_' + str(resolution) +'um.nii.gz')



