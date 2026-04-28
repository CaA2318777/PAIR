import copy
import os

import pathlib
from pathlib import Path

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt

from ClearMap.IO import IO as clearmap_io

from ClearMap import Settings as settings
from ClearMap.Alignment import Annotation as ano
from ClearMap.Alignment import Resampling as res
from ClearMap.Alignment import Elastix as elx
import json
import SimpleITK as sitk

with open('config.json', 'r') as f:
    config = json.load(f)

mice_num =  config.get('mice_num')
resolution = config.get('resolution')
method1 = config.get('method')
ifresult = config.get('ifresult')

print('import end')


fixed_path = '/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/step1_' + method1 + '/' + method1 + '_warped_atlas_' + str(resolution) +'um.nii.gz'
moving_path = '/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/origin/' + '/ims_data_25um.nii.gz'
ims_result_path = '/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/origin/' + '/ims_data_result_25um.nii.gz'
saving_path = '/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/' + str(mice_num) + '/'+str(resolution) +'um/'+ '/step2_' + method1 + '_clearmap/'


if ifresult:
    print("############################################################")
    print("###################   ims protein      #####################")
    print("############################################################")

    transformix_binary = '/home/xxx/miniconda3-/envs/ClearMapUi39/lib/python3.9/site-packages/ClearMap2-2.1.4-py3.9-linux-x86_64.egg/ClearMap/External/elastix/build/bin/transformix'    
    cmd = f'{transformix_binary} -in {ims_result_path} -out {saving_path} -tp {saving_path+"TransformParameters.1.txt"}'
    res = os.system(cmd)
    image = sitk.ReadImage(saving_path + "result.mhd")
    sitk.WriteImage(image, saving_path + method1 + '_clearmap_warped_ims_result_' + str(resolution) +'um.nii.gz')