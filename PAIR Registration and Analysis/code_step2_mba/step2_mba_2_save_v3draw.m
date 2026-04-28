clear all

addpath D:/v3d_external-master/matlab_io_basicdatatype

for mice_num = [361,363]
reg_resolution = 25;
add_res = 0;
method1 = 'vm';

datapath = ['Y:/xxx/xxx/Data/2024/240926_align/',num2str(mice_num),'/', num2str(reg_resolution),'um/'];


Warped_CCF_target_path = [datapath,'/','/step2_',method1,'_mba/Warped_CCF_target/atlas_v3draw/'];
mba_path_plan1 = [datapath,'/','/step2_',method1,'_mba/Warped_CCF_target/'];
copyfile(['Y:\xxx\xxx\Data\2024\240828_align\270.2\25um\mba\plan1\','config.txt'], [datapath,'/','/step2_',method1,'_mba/config.txt'])

%% 把mat数据存成v3draw
% 调用系统命令并获取输出
line1 = ['D:/anaconda3/envs/seg/python.exe '];
line2 = ['Y:/xxx/xxx/xxx/2024/240926_new_align/code_step2_mba/save_v3draw.py']
line3 = [' -r ' , num2str(reg_resolution) , ' -num ' , num2str(mice_num), ' -method1 ', method1];

line = [line1,line2,line3];
[status, cmdout] = system(line);

% 显示命令执行状态
disp(['命令执行状态: ', num2str(status)]);

% 显示命令输出
disp(['命令输出: ', cmdout]);
mba_path_plan1 = [datapath,'/','/step2_',method1,'_mba/Warped_CCF_target/'];

% if strcmp(method1,'vm')
%     mkdir([datapath,'/step2_vm_mba'])
%     copyfile([datapath,'/step2_ants_mba/ims_data.v3draw'],[datapath,'/step2_vm_mba/ims_data.v3draw'])
% end


%% 2.5D
% line1 = ['F:/mBrainAligner/binary/win64_bin/2.5D_Harris.exe '];
% line2 = ['-i ' , Warped_CCF_target_path, '/CCF_u8_xpad.v3draw ']; 
% line3 = ['-o ', mba_path_plan1,'/ '];
% line4 = '-q 30';
% line = [line1,line2,line3,line4];
% disp(line)
% [status, cmdout] = dos(line);
% disp(cmdout);
% 
% % 显示命令执行状态
% disp(['命令执行状态: ', num2str(status)]);
% % 显示命令输出
% disp(['命令输出: ', cmdout]);


end
%% local config
% multilineStr = ['Select_modal = 1' newline ...
%                 'max_iteration_number = 1500' newline ...
%                 'smoothness_constraint_outer_initial = 1' newline ...
%                 'smoothness_constraint_inner_initial=100' newline ...
%                 'smoothness_constraint_outer_end = 1' newline ...
%                 'smoothness_constraint_inner_end = 10' newline ...
%                 'kernel_radius = 10' newline ...
%                 'search_radius=5' newline ...
%                 'interval_save = 100' newline ...
%                 'interval_region_constraint = 25' newline ...
%                 'multiscale = 1' newline ...
%                 'interval_global_constraint = 50' newline ...
%                 ];
% 
% fileID = fopen([mba_path_plan1,'config.txt'], 'wt');
% % 检查文件是否成功打开
% if fileID == -1
%     error('File cannot be opened');
% else
%     fprintf(fileID, multilineStr);
% end

