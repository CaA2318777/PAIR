# %% 
# calculating jacobian for method: clearmap
import SimpleITK as sitk
import json
import pathlib
import numpy as np
import scipy
import nibabel as nib
import os
import re

# Function to compute Jacobian determinant from the deformation field
def compute_jacobian_determinant(deformation_field):
    # Compute the gradients (partial derivatives) of the deformation field
    #grad_x, grad_y, grad_z = np.gradient(deformation_field, axis = (0,1,2))
    grad_x_1 = scipy.ndimage.sobel(deformation_field[..., 0], axis=0) + 1  # Sobel filter in x-direction
    grad_x_2 = scipy.ndimage.sobel(deformation_field[..., 0], axis=1)
    grad_x_3 = scipy.ndimage.sobel(deformation_field[..., 0], axis=2)
 
    grad_y_1 = scipy.ndimage.sobel(deformation_field[..., 1], axis=0)  # Sobel filter in y-direction
    grad_y_2 = scipy.ndimage.sobel(deformation_field[..., 1], axis=1) + 1
    grad_y_3 = scipy.ndimage.sobel(deformation_field[..., 1], axis=2)
 
    grad_z_1 = scipy.ndimage.sobel(deformation_field[..., 2], axis=0)  # Sobel filter in z-direction
    grad_z_2 = scipy.ndimage.sobel(deformation_field[..., 2], axis=1)
    grad_z_3 = scipy.ndimage.sobel(deformation_field[..., 2], axis=2) + 1


    # Calculate the Jacobian determinant at each voxel
    #jacobian_determinant = (grad_x[...,0]*(grad_y[...,1]*grad_z[...,2]-grad_y[...,2]*grad_z[...,1]))-(grad_x[...,1]*(grad_y[...,0]*grad_z[...,2]-grad_y[...,2]*grad_z[...,0])) + (grad_x[...,2]*(grad_y[...,0]*grad_z[...,1]-grad_y[...,1]*grad_z[...,0]))
    jacobian_determinant = (grad_x_1*(grad_y_2*grad_z_3-grad_y_3*grad_z_2))-(grad_x_2*(grad_y_1*grad_z_3-grad_y_3*grad_z_1))+(grad_x_3*(grad_y_1*grad_z_2-grad_y_2*grad_z_1))
    print(jacobian_determinant.shape)

    return jacobian_determinant

def ndgrid(*args, **kwargs):
    kwargs['indexing'] = 'ij'
    return np.meshgrid(*args, **kwargs)

def volsize2ndgrid(volsize):
    ranges = [np.arange(e) for e in volsize]
    return ndgrid(*ranges)

def cal_jacobian_determinant(disp):
    """
    jacobian determinant of a displacement field.
    NB: to compute the spatial gradients, we use np.gradient.

    Parameters:
        disp: 2D or 3D displacement field of size [*vol_shape, nb_dims], 
              where vol_shape is of len nb_dims

    Returns:
        jacobian determinant (scalar)
    """

    # check inputs
    volshape = disp.shape[:-1]
    nb_dims = len(volshape)
    assert len(volshape) in (2, 3), 'flow has to be 2D or 3D'

    # compute grid
    grid_lst = volsize2ndgrid(volshape)
    grid = np.stack(grid_lst, len(volshape))

    # compute gradients
    J = np.gradient(disp + grid)

    # 3D glow
    if nb_dims == 3:
        dx = J[0]
        dy = J[1]
        dz = J[2]

        # compute jacobian components
        Jdet0 = dx[..., 0] * (dy[..., 1] * dz[..., 2] - dy[..., 2] * dz[..., 1])
        Jdet1 = dx[..., 1] * (dy[..., 0] * dz[..., 2] - dy[..., 2] * dz[..., 0])
        Jdet2 = dx[..., 2] * (dy[..., 0] * dz[..., 1] - dy[..., 1] * dz[..., 0])

        return Jdet0 - Jdet1 + Jdet2

    else:  # must be 2

        dfdx = J[0]
        dfdy = J[1]

        return dfdx[..., 0] * dfdy[..., 1] - dfdy[..., 0] * dfdx[..., 1]
    
def modify_transform_file(parameters_path):
    """
    Modify a transform parameter file. Specifically change GridSpacing and GridOrigin.
    
    Parameters:
        input_file (str): Path to the original transform parameter file.
        output_file (str): Path to save the modified transform parameter file.
    """
    with open(parameters_path+'TransformParameters.1.txt', 'r') as file:
        lines = file.readlines()
    
    lines = []
    
    for line in lines:
        if line.strip().startswith("(InitialTransformParametersFileName"):
            # Skip InitialTransformParametersFileName setting
            continue
        elif line.strip().startswith("(Size"):
            print(line)
            numbers = re.findall(r'-?\d+\.\d+|-?\d+', line)
            size_x, size_y, size_z = map(float, numbers)
            print(size_x, size_y, size_z)
            lines.append(line)
        elif line.strip().startswith("(GridSize"):
            print(line)
            numbers = re.findall(r'-?\d+\.\d+|-?\d+', line)
            control_point_x, control_point_y, control_point_z = map(float, numbers)
            print(control_point_x,control_point_y,control_point_z)
            lines.append(line)
        elif line.strip().startswith("(GridSpacing"):
            print(line)
            new_spacing_x = size_x/control_point_x
            new_spacing_y = size_y/control_point_y
            new_spacing_z = size_z/control_point_z
            print(new_spacing_x,new_spacing_y,new_spacing_z)
            lines.append(f"(GridSpacing {new_spacing_x:.10f} {new_spacing_y:.10f} {new_spacing_z:.10f})\n")
            print(f"(GridSpacing {new_spacing_x:.10f} {new_spacing_y:.10f} {new_spacing_z:.10f})\n")
        elif line.strip().startswith("(GridOrigin"):
            print(line)
            lines.append(f"(GridOrigin {new_spacing_x:.10f} {new_spacing_y:.10f} -{new_spacing_z:.10f})\n")
        else:
            # Retain all other lines
            lines.append(line)
    
    # Write the modified content to the output file
    with open(parameters_path+'TransformParameters.1.txt', 'w') as file:
        file.writelines(lines)
    print("TransformParameters.1.txt saved")


current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]



mice_num =  270
resolution = 25
# path to load TransformParameters.1.txt
traditional_datapath = path_before_hd6 + '/xxx/xxx/Data/2024/241113_final_brains/' + str(mice_num) + '/' + str(resolution) + 'um/' + 'traditional_clearmap/' 
ants_two_step_datapath = path_before_hd6 + '/xxx/xxx/Data/2024/241113_final_brains/' + str(mice_num) + '/' + str(resolution) + 'um/step2_ants_clearmap/' 
vm_two_step_datapath = path_before_hd6 + '/xxx/xxx/Data/2024/241113_final_brains/' + str(mice_num) + '/' + str(resolution) + 'um/step2_vm_clearmap/'

# modify_transform_file(traditional_datapath)
# modify_transform_file(ants_two_step_datapath)
# modify_transform_file(vm_two_step_datapath)

# path to save jacobians and overall statistics
savepath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/temp/'  + 'clearmap_jacobian'
traditional_savepath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/temp/' + 'traditional_clearmap_jacobian'
ants_two_step_savepath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/temp/' + 'ants_two_step_clearmap_jacobian'
vm_two_step_savepath = path_before_hd6 + '/xxx/xxx/Data/2024/240926_align/temp/' + 'vm_two_step_clearmap_jacobian'
pathlib.Path(savepath).mkdir(parents=True, exist_ok=True)
pathlib.Path(traditional_savepath).mkdir(parents=True, exist_ok=True)
pathlib.Path(ants_two_step_savepath).mkdir(parents=True, exist_ok=True)
pathlib.Path(vm_two_step_savepath).mkdir(parents=True, exist_ok=True)





# path to save statistics .txt file
my_file_path = savepath + "/negative_jacobian_percentages.txt"
simpleitk_file_path = savepath + "/negative_jacobian_percentages_by_sitk.txt" 

# generating deformation field, jacobian determinant image, jacobian matrix
transformix_binary = '/home/xxx/miniconda3/envs/ClearMapUi39/lib/python3.9/site-packages/ClearMap2-2.1.4-py3.9-linux-x86_64.egg/ClearMap/External/elastix/build/bin/transformix'
cmd = f'{transformix_binary} -def all -jac all -jacmat all -out {traditional_savepath} -tp {traditional_datapath+"TransformParameters.0.txt"}'
res = os.system(cmd)


traditional_deformation_field = sitk.ReadImage(traditional_savepath+"/deformationField.mhd")
traditional_deformation_field = sitk.GetArrayFromImage(traditional_deformation_field)
traditional_deformation_field = traditional_deformation_field.transpose(2,1,0,3)
traditional_deformation_field1 = np.expand_dims(traditional_deformation_field, axis = 3)
traditional_deformation_field_nii = nib.Nifti1Image(traditional_deformation_field1, affine = np.eye(4))
nib.save(traditional_deformation_field_nii, traditional_savepath+"/deformationField_affine.nii.gz")
print('affine saved')


# generating deformation field, jacobian determinant image, jacobian matrix
transformix_binary = '/home/xxx/miniconda3/envs/ClearMapUi39/lib/python3.9/site-packages/ClearMap2-2.1.4-py3.9-linux-x86_64.egg/ClearMap/External/elastix/build/bin/transformix'
cmd = f'{transformix_binary} -def all -jac all -jacmat all -out {traditional_savepath} -tp {traditional_datapath+"TransformParameters.1.txt"}'
res = os.system(cmd)


traditional_deformation_field = sitk.ReadImage(traditional_savepath+"/deformationField.mhd")
traditional_deformation_field = sitk.GetArrayFromImage(traditional_deformation_field)
traditional_deformation_field = traditional_deformation_field.transpose(2,1,0,3)
traditional_deformation_field2 = np.expand_dims(traditional_deformation_field, axis = 3)
traditional_deformation_field_nii = nib.Nifti1Image(traditional_deformation_field2, affine = np.eye(4))
nib.save(traditional_deformation_field_nii, traditional_savepath+"/deformationField_all.nii.gz")
print('all saved')

traditional_deformation_field_bspline = traditional_deformation_field2-traditional_deformation_field1
traditional_deformation_field_nii = nib.Nifti1Image(traditional_deformation_field_bspline, affine = np.eye(4))
nib.save(traditional_deformation_field_nii, traditional_savepath+"/deformationField_bspline.nii.gz")
print('bspline saved')








print('end')
exit(0)
cmd_2 = f'{transformix_binary} -def all -jac all -jacmat all -out {ants_two_step_savepath} -tp {ants_two_step_datapath+"TransformParameters.0.txt"}'
res_2 = os.system(cmd_2)

cmd_3 = f'{transformix_binary} -def all -jac all -jacmat all -out {vm_two_step_savepath} -tp {vm_two_step_datapath+"TransformParameters.0.txt"}'
res_3 = os.system(cmd_3)




# My Calculation of Jacobian
# traditional clearmap
deformation_field = sitk.ReadImage(traditional_savepath+"/deformationField.mhd")
deformation_field = sitk.GetArrayFromImage(deformation_field)
#jacobian_determinant = compute_jacobian_determinant(deformation_field)
jacobian_determinant = cal_jacobian_determinant(deformation_field)
jacobian_nii = nib.Nifti1Image(jacobian_determinant, affine=np.eye(4))
#nib.save(jacobian_nii, savepath+'/traditional_clearmap_jacobian.nii.gz')
negative_jacobian = np.sum(jacobian_determinant<0)
total_jacobian = np.prod(jacobian_determinant.shape)
negative_jacobian_percentage = (negative_jacobian / total_jacobian) * 100
with open(my_file_path, 'a') as file:
    file.write(f"Percentage of negative Jacobian determinants for traditional clearmap: {negative_jacobian_percentage:.2f}%\n")

# two-step ants clearmap
deformation_field = sitk.ReadImage(ants_two_step_savepath+"/deformationField.mhd")
deformation_field = sitk.GetArrayFromImage(deformation_field)
jacobian_determinant = cal_jacobian_determinant(deformation_field)
jacobian_nii = nib.Nifti1Image(jacobian_determinant, affine=np.eye(4))
#nib.save(jacobian_nii, savepath+'/two_step_ants_jacobian.nii.gz') 
negative_jacobian = np.sum(jacobian_determinant<0)
total_jacobian = np.prod(jacobian_determinant.shape)
negative_jacobian_percentage = (negative_jacobian / total_jacobian) * 100
with open(my_file_path, 'a') as file:
    file.write(f"Percentage of negative Jacobian determinants for two-step ants clearmap: {negative_jacobian_percentage:.2f}%\n")

# two-step vm clearmap
deformation_field = sitk.ReadImage(vm_two_step_savepath+"/deformationField.mhd")
deformation_field = sitk.GetArrayFromImage(deformation_field)
jacobian_determinant = cal_jacobian_determinant(deformation_field)
jacobian_nii = nib.Nifti1Image(jacobian_determinant, affine=np.eye(4))
#nib.save(jacobian_nii, savepath+'/two_step_vm_jacobian.nii.gz') 
negative_jacobian = np.sum(jacobian_determinant<0)
total_jacobian = np.prod(jacobian_determinant.shape)
negative_jacobian_percentage = (negative_jacobian / total_jacobian) * 100
with open(my_file_path, 'a') as file:
    file.write(f"Percentage of negative Jacobian determinants for two-step vm clearmap: {negative_jacobian_percentage:.2f}%\n")






 