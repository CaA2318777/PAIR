
clear all

addpath D:/v3d_external-master/matlab_io_basicdatatype
for mice_num = [358 359 360 361 363]
reg_resolution = 25;
add_res = 0;

datapath = ['/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/',num2str(mice_num),'/'];
ims_v3draw_path = [datapath,num2str(reg_resolution),'um/','step2_vm_mba', '/'];
CCF_target_path =['/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/','CCF_target/atlas_v3draw/'];
Warped_IMS_result_path = [datapath,num2str(reg_resolution),'um/','traditional_mba', '/Warped_IMS_result/'];

mkdir(['Y:/xxx/xxx/Data/2024/240926_align/',num2str(mice_num),'/',num2str(reg_resolution),'um/','traditional_mba', '/Warped_IMS_result/'])
% mkdir(PA_target_path)
% mkdir(Warped_CCF_result_path)
% mkdir(CCF_target_path)
% mkdir(Warped_IMS_result_path)

%% global 


line1 = ['/home/xxx/LabFiles1/xxx/xxx/xxx/2024/240926_new_align/mBrainAligner/binary/linux_bin/global_registration',' '];
line2 = ['-f ' , '/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/','CCF_target/',' '];
line3 = ['-m ' , ims_v3draw_path,'/ims_data.v3draw',' '];
line4 = '-p r+f ';
line5 = ['-o ' , Warped_IMS_result_path,' '];
line6 = '-d 0 -l 30+30+30 -u 1';

line = [line1,line2,line3,line4,line5,line6];
disp(line)


%% local

line1 = ['/home/xxx/LabFiles1/xxx/xxx/xxx/2024/240828_align/mBrainAligner/binary/linux_bin/local_registration ']; 
line3 = ['-p ' , ims_v3draw_path, '/config.txt ']; 
line4 = ['-s ', Warped_IMS_result_path, '/global.v3draw '];
line5 = ['-l ',  '/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/','CCF_target/','/corner_Harris2.5D.marker '];
line6 = ['-g ', '/home/xxx/LabFiles1/xxx/xxx/Data/2024/240926_align/','CCF_target/ '];
line7 = ['-o ', Warped_IMS_result_path,' '];
line8 = '-u 1';
line = [line1,line3,line4,line5,line6,line7,line8];
disp(line)

end