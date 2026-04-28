clear all

addpath D:\v3d_external-master\matlab_io_basicdatatype
mice_num = 363;
reg_resolution = 25;
add_res = 0;


datapath = ['Y:\xxx\xxx\Data\2024\240926_align\',num2str(mice_num),'\',num2str(reg_resolution),'um\'];
traditional_amap_path = [datapath,'traditional_amap\'];
mkdir(traditional_amap_path)



%%
temp = load_nii([datapath,'origin\Atlas_',num2str(reg_resolution),'um.nii.gz']);
Atlas = temp.img;
Atlas = uint16(Atlas);
Atlas = permute(Atlas,[3,1,2]);
Atlas = flip(Atlas, 3);
Atlas = flip(Atlas, 1);
% Atlas = padarray(Atlas, [4, 4, 4], 0, 'both');

if exist([traditional_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'], 'file') == 2
    delete([traditional_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff']);
end
save_tif(Atlas,[traditional_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'])

%%
temp = load_nii([datapath,'origin\Annotation_',num2str(reg_resolution),'um.nii.gz']);
Annotation = temp.img;
Annotation = uint16(Annotation);
Annotation = permute(Annotation,[3,1,2]);
Annotation = flip(Annotation, 3);
Annotation = flip(Annotation, 1);
% Annotation = padarray(Atlas, [4, 4, 4], 0, 'both');
if exist([traditional_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff'], 'file') == 2
    delete([traditional_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff']);
end
save_tif(Annotation,[traditional_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff'])

%% origin ims data

if exist([datapath,'\step2_vm_amap\amap_ims_data_',num2str(reg_resolution),'um.tiff'], 'file') == 2
    copyfile([datapath,'\step2_vm_amap\amap_ims_data_',num2str(reg_resolution),'um.tiff'],[traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'])
    disp('copy')
else
    temp = load_nii([datapath,'origin\ims_data_',num2str(reg_resolution),'um.nii.gz']);
    ims_data = temp.img;
    ims_data = uint16(ims_data);
    ims_data = permute(ims_data,[3,1,2]);
    ims_data = flip(ims_data, 3);
    ims_data = flip(ims_data, 1);
    
    if exist([traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], 'file') == 2
        delete([traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff']);
    end
    save_tif(ims_data,[traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'])
end
%% expert origin ims anno  还没改
% temp = load_nii([datapath,'origin\ims_data_',num2str(reg_resolution),'um.nii.gz']);
% ims_data = temp.img;
% ims_data = uint16(ims_data);
% ims_data = permute(ims_data,[3,1,2]);
% ims_data = flip(ims_data, 3);
% ims_data = flip(ims_data, 1);
% 
% if exist([traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], 'file') == 2
%     delete([traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff']);
% end
% save_tif(ims_data,[traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'])

%%
savepath = 'C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\';
copyfile([traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], [savepath,'reference.tiff']);
copyfile([traditional_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], [savepath,'annotation.tiff']);


%%
addpath D:\matlab2021b\toolbox\jsonlab-master

% 1.新建.json文件
fid= fopen('C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\metadata.json', 'w');
 
% step 1: 读取json文件
file_name = 'C:\Users\xxx\.brainglobe\allen_mouse_100um_v1.2\metadata.json'; % 待读取的文件名称
jsonData = loadjson(file_name); % jsonData是个struct结构
jsonData.shape = size(Annotation);
jsonData.resolution = [25,25,25];

% step 4：将数据json结构转化为字符串结构
json=savejson('',jsonData);
% 2.写入json文件进行保存
fprintf(fid, '%s',json);
disp('save json')
%%

fake_ims_path = [traditional_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'];

line1 = 'conda activate brainreg1';
disp(line1)
line2 = ['brainreg ', fake_ims_path,' ',traditional_amap_path,' -v 25 25 25 --orientation asl --atlas allen_mouse_25um'];
disp(line2)
