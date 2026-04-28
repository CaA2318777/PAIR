clear all

addpath D:\v3d_external-master\matlab_io_basicdatatype
reg_resolution = 25;
add_res = 0;
method1 = 'vm';

for mice_num = [358 359 360 361 363]


    
    datapath = ['Y:\xxx\xxx\Data\2024\240926_align\',num2str(mice_num),'\',num2str(reg_resolution),'um\'];
    step2_amap_path = [datapath,'step2_',method1,'_amap\'];
    mkdir(step2_amap_path)
    disp(mice_num)
    
     %%
    temp = load_nii([datapath,'step1_',method1,'\',method1,'_warped_atlas_',num2str(reg_resolution),'um.nii.gz']);
    Atlas = temp.img;
    Atlas = uint16(Atlas);
    Atlas = permute(Atlas,[3,1,2]);
    Atlas = flip(Atlas, 3);
    Atlas = flip(Atlas, 1);
    if exist([step2_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'], 'file') == 2
        delete([step2_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff']);
    end
    save_tif(Atlas,[step2_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'])
    disp('Atlas end')
    
    %%
    temp = load_nii([datapath,'step1_',method1,'\',method1,'_warped_anno_',num2str(reg_resolution),'um.nii.gz']);
    Annotation = temp.img;
    Annotation = uint16(Annotation);
    Annotation = permute(Annotation,[3,1,2]);
    Annotation = flip(Annotation, 3);
    Annotation = flip(Annotation, 1);
    if exist([step2_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff'], 'file') == 2
        delete([step2_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff']);
    end
    save_tif(Annotation,[step2_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff'])
    disp('Annotation end')
    
    %% ims
    temp = load_nii([datapath,'origin\ims_data_',num2str(reg_resolution),'um.nii.gz']);
    ims_data = double(temp.img);

    ims_data(ims_data<800) = 0;
%     ims_data = ims_data-1000;
%     ims_data(ims_data==-800) = 0;
%     disp(mean(ims_data(:)))
%     ims_data = ims_data./5;
    
%     ims_data = ims_data./50 *1300;

    
    ims_data = permute(ims_data,[3,1,2]);
    ims_data = flip(ims_data, 3);
    ims_data = flip(ims_data, 1);
    ims_data(ims_data>13000) = 13000;
    figure;imagesc(squeeze(ims_data(:,:,250)));colormap gray
    ims_data = uint16(ims_data);
    if exist([step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], 'file') == 2
        delete([step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff']);
    end

    %翻过来了
    ims_data = flip(ims_data, 2);
    save_tif(ims_data,[step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'])
    disp('ims end')
    
    
    % %%
    % savepath = 'C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\';
    % copyfile([step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], [savepath,'reference.tiff']);
    % copyfile([step2_amap_path,'\amap_ims_data_',num2str(reg_resolution),'um.tiff'], [savepath,'annotation.tiff']);
    % 
    % 
    % %%
    % addpath D:\matlab2021b\toolbox\jsonlab-master
    % 
    % % 1.新建.json文件
    % fid= fopen('C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\metadata.json', 'w');
    %  
    % % step 1: 读取json文件
    % file_name = 'C:\Users\xxx\.brainglobe\allen_mouse_100um_v1.2\metadata.json'; % 待读取的文件名称
    % jsonData = loadjson(file_name); % jsonData是个struct结构
    % jsonData.shape = size(Annotation);
    % jsonData.resolution = [25,25,25];
    % 
    % % step 4：将数据json结构转化为字符串结构
    % json=savejson('',jsonData);
    % % 2.写入json文件进行保存
    % fprintf(fid, '%s',json);
    % disp('save json')
    % %%
    % 
    % fake_ims_path = [step2_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'];
    % 
    % line1 = 'conda activate brainreg1';
    % disp(line1)
    % line2 = ['brainreg ', fake_ims_path,' ',step2_amap_path,' -v 25 25 25 --orientation asl --atlas allen_mouse_25um'];
    % disp(line2)

end