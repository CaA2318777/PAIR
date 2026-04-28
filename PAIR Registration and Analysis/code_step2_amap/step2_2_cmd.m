clear all

addpath D:\v3d_external-master\matlab_io_basicdatatype

reg_resolution = 25;
add_res = 0;
method1 = 'vm';


for mice_num = [358 359 360 361 363]

    datapath = ['Y:\xxx\xxx\Data\2024\240926_align\',num2str(mice_num),'\',num2str(reg_resolution),'um\'];
    step2_amap_path = [datapath,'step2_',method1,'_amap\'];
%     mkdir(step2_amap_path)
    
    %%
    temp = load_nii([datapath,'step1_',method1,'\',method1,'_warped_anno_',num2str(reg_resolution),'um.nii.gz']);
    Annotation = temp.img;
    Annotation = uint16(Annotation);
    Annotation = permute(Annotation,[3,1,2]);
    
    
    
    %%
    savepath = 'C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\';
    copyfile([step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], [savepath,'reference.tiff']);
    copyfile([step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], [savepath,'annotation.tiff']);
    
    
    %%
    addpath D:\matlab2021b\toolbox\jsonlab-master
    
    % 1.新建.json文件
%     fid= fopen('C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\metadata.json', 'w');
    fid= fopen([step2_amap_path,'\metadata.json'], 'w');

    % step 1: 读取json文件
    file_name = 'C:\Users\xxx\.brainglobe\allen_mouse_100um_v1.2\metadata.json'; % 待读取的文件名称
    jsonData = loadjson(file_name); % jsonData是个struct结构
    jsonData.shape = size(Annotation);
    jsonData.resolution = [25,25,25];
    
    % step 4：将数据json结构转化为字符串结构
    json=savejson('',jsonData);
    % 2.写入json文件进行保存
    fprintf(fid, '%s',json);
%     disp('save json')

    %%
    line0 = ['copy ', [step2_amap_path,'\metadata.json'], ' ', 'C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\metadata.json'];
    disp(line0)
    line01 = ['copy ', [step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff '], [savepath,'reference.tiff']];
    line02 = ['copy ', [step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff '], [savepath,'annotation.tiff']];
    disp(line01)
    disp(line02)
    fake_ims_path = [step2_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'];
    
%     line1 = 'conda activate brainreg1';
%     disp(line1)
    line2 = ['brainreg ', fake_ims_path,' ',step2_amap_path,' -v 25 25 25 --orientation asl --atlas allen_mouse_25um'];
    disp(line2)
end