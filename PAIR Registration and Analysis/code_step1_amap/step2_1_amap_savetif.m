clear all
addpath Y:\xxx\xxx\xxx\2024\240926_new_align\code_step2_mba
addpath D:\v3d_external-master\matlab_io_basicdatatype
reg_resolution = 25;
add_res = 0;


for mice_num = [372]


    
    datapath = ['Y:\xxx\xxx\Data\2024\240926_align\',num2str(mice_num),'\',num2str(reg_resolution),'um\'];
    step1_amap_path = [datapath,'step1_amap\'];
    mkdir(step1_amap_path)
    disp(mice_num)


    
    traditional_amap_path = [datapath,'traditional_amap\'];
    if ~(exist([traditional_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'], 'file') == 2)
        disp('NO amap_Atlas')
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
        mkdir(traditional_amap_path)
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
    
    end

    copyfile([traditional_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff'],[step1_amap_path,'\amap_Annotation_',num2str(reg_resolution),'um.tiff'])
    copyfile([traditional_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'],[step1_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'])
    

    
    %% 读取pa_bg
    temp = load_nii([datapath,'origin\pa_bg_',num2str(reg_resolution),'um.nii.gz']);
    
    pa_bg = double(temp.img);
    pa_bg(pa_bg<-10) = -10;
    pa_bg = (pa_bg);

    
    pa_bg = permute(pa_bg,[3,1,2]);
    pa_bg = flip(pa_bg, 3);
    pa_bg = flip(pa_bg, 1);
    pa_bg(pa_bg>1300) = 1300;
    figure;imagesc(squeeze(pa_bg(:,:,300)));colormap gray
    pa_bg = uint16(pa_bg);
    if exist([step1_amap_path,'\amap_pa_bg_',num2str(reg_resolution),'um.tiff'], 'file') == 2
        delete([step1_amap_path,'\amap_pa_bg_',num2str(reg_resolution),'um.tiff']);
    end
    save_tif(pa_bg,[step1_amap_path,'\amap_pa_bg_',num2str(reg_resolution),'um.tiff'])
    disp('pa end')
    
    
    % %%
    % savepath = 'C:\Users\xxx\.brainglobe\allen_mouse_25um_v1.2\';
    % copyfile([step1_amap_path,'\amap_pa_bg_',num2str(reg_resolution),'um.tiff'], [savepath,'reference.tiff']);
    % copyfile([step1_amap_path,'\amap_pa_bg_',num2str(reg_resolution),'um.tiff'], [savepath,'annotation.tiff']);
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
    % fake_ims_path = [step1_amap_path,'\amap_Atlas_',num2str(reg_resolution),'um.tiff'];
    % 
    % line1 = 'conda activate brainreg1';
    % disp(line1)
    % line2 = ['brainreg ', fake_ims_path,' ',step1_amap_path,' -v 25 25 25 --orientation asl --atlas allen_mouse_25um'];
    % disp(line2)

end