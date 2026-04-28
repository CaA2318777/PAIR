import copy
import os

import pathlib
from pathlib import Path

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt

from ClearMap.IO import IO as clearmap_io
from ClearMap.IO import Workspace as wsp
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

pathlib.Path(saving_path).mkdir(parents=True, exist_ok=True) 
print('load end')
resources_directory = settings.resources_path

# ws.info()




# init atlas and reference files
annotation_file, reference_file, distance_file=ano.prepare_annotation_files(
    slicing=(slice(None),slice(None),slice(None)), orientation=(1,2,3),
    overwrite=False, verbose=True);

# alignment parameter files
align_channels_affine_file   = clearmap_io.join(resources_directory, 'Alignment/align_affine.txt')
align_reference_affine_file  = clearmap_io.join(resources_directory, 'Alignment/align_affine.txt')
align_reference_bspline_file = clearmap_io.join(resources_directory, 'Alignment/align_bspline.txt')

print(align_reference_affine_file)


# align autofluorescence to reference
align_reference_parameter = {
    # moving and reference images
    "moving_image" : moving_path,
    "fixed_image"  : fixed_path,

    # elastix parameter files for alignment
    "affine_parameter_file"  :  align_reference_affine_file,
    "bspline_parameter_file" :  align_reference_bspline_file,
    # directory of the alignment result
    "result_directory" :  (saving_path)
    }

elx.align(**align_reference_parameter)




image = sitk.ReadImage(saving_path + "result.1.mhd")
sitk.WriteImage(image, saving_path + method1 + '_clearmap_warped_ims_' + str(resolution) +'um.nii.gz')
