
clear all

addpath D:/v3d_external-master/matlab_io_basicdatatype
mice_num = 323;
reg_resolution = 25;
add_res = 0;
method1 = 'ants';

window_datapath = 'Y:\xxx\xxx\Data\2024\240926_align\';
software_path_aladin = '/home/xxx/LabFiles1/xxx/xxx/xxx/2024/240828_align/niftyreg/build/reg-apps/reg_aladin ';
software_path_f3d = '/home/xxx/LabFiles1/xxx/xxx/xxx/2024/240828_align/niftyreg/build/reg-apps/reg_f3d ';

datapath = ['/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/',num2str(mice_num),'/', num2str(reg_resolution),'um/'];
savepath = [datapath,'step2_',method1,'_niftyreg/'];
mkdir([window_datapath,'step2_',method1,'_niftyreg/'])


%% 

method1_atlas_ref = ['-ref ', datapath, 'step1_',method1,'/',method1,'_warped_atlas_', num2str(reg_resolution),'um.nii.gz '];
flo_aff = ['-flo ',datapath, 'origin/ims_data_', num2str(reg_resolution),'um.nii.gz '];
res_aff = ['-res ', savepath, '/',method1,'_nintyreg_warped_aff_ims_', num2str(reg_resolution),'um.nii.gz '];

%%
disp('----------------------step2 niftyreg-----------------------')
tranditional_line_affine = [software_path_aladin, method1_atlas_ref, flo_aff, res_aff];
disp(tranditional_line_affine)

flo_final = ['-flo ', savepath, '/',method1,'_nintyreg_warped_aff_ims_', num2str(reg_resolution),'um.nii.gz '];
res_final = ['-res ', savepath, '/',method1,'_nintyreg_warped_ims_', num2str(reg_resolution),'um.nii.gz '];

tranditional_line_final = [software_path_f3d, method1_atlas_ref, flo_final, res_final,' -sx 40'];
disp(tranditional_line_final)

