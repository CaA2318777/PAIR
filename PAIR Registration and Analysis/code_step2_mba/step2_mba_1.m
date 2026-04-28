clear all

addpath D:\v3d_external-master\matlab_io_basicdatatype


for mice_num = [358,359,360,361,363]

    reg_resolution = 25;
    add_res = 0;
    method1 = 'vm';
    
    
    datapath = ['Y:\xxx\xxx\Data\2024\240926_align\',num2str(mice_num),'\'];
    
    mba_path = [datapath,'\',num2str(reg_resolution),'um\step2_',method1,'_mba\'];
    Warped_CCF_target_path = [datapath,'\',num2str(reg_resolution),'um\step2_',method1,'_mba\Warped_CCF_target\atlas_v3draw\'];
    Warped_IMS_result_path = [datapath,'\',num2str(reg_resolution),'um\step2_',method1,'_mba\Warped_IMS_result\'];
    
    
    mkdir(Warped_CCF_target_path)
    mkdir(Warped_IMS_result_path)
    
    
    %% Read PA and write to Warped_CCF_target_path
%     temp = load_nii([datapath,num2str(reg_resolution),'um\step1_', method1,'\',method1,'_warped_atlas_',num2str(reg_resolution),'um.nii.gz']);
%     warped_Atlas=temp.img;
%     warped_Atlas = permute(warped_Atlas,[2,1,3]);
%     warped_Atlas = flip(warped_Atlas,2);
%     warped_Atlas = permute(warped_Atlas,[3,1,2]);
%     warped_Atlas = flip(warped_Atlas,2);
%     
%     [x,y,z] = size(warped_Atlas);
%     new_pabg = zeros(x+4+mod(x,2),y+4+mod(y,2),z+4+mod(z,2));
%     new_pabg(3:x+2,3:y+2,3:z+2) = warped_Atlas;
%     
%     
%     
%     
%     temp = load_nii([datapath,num2str(reg_resolution),'um\step1_', method1,'\',method1,'_warped_anno_',num2str(reg_resolution),'um.nii.gz']);
%     warped_Annotation = temp.img;
%     warped_anno = permute(warped_Annotation,[2,1,3]);
%     warped_anno = flip(warped_anno,2);
%     warped_anno = permute(warped_anno,[3,1,2]);
%     warped_anno = flip(warped_anno,2);
%     
%     [x,y,z] = size(warped_anno);
%     warped_Annotation = zeros(x+4+mod(x,2),y+4+mod(y,2),z+4+mod(z,2));
%     warped_Annotation(3:x+2,3:y+2,3:z+2) = warped_anno;
%     % warped_Annotation = warped_anno;
%     
%     %-------------------------------------
%     % clear new_pabg2
%     % for iii = 1:size(new_pabg,2)
%     %     new_pabg2(:,iii,:) = imrotate(squeeze(new_pabg(:,iii,:)), 7,'bilinear');
%     % end
%     %-------------------------------------
%     
%     
%     warped_Atlas = new_pabg;
%     mask = new_pabg;
%     mask(mask<=5) = 0;
%     mask(mask~=0) = 1; 
%     
%     mask = bwareaopen(mask,300000);
%     mask = -mask +1;
%     mask = bwareaopen(mask,300000);
%     mask = -mask +1;
%     mask = double(mask);
%     
%     se = strel('cube', 3);
%     V_dilated = imerode(mask, se);
%     V_dilated2 = imerode(V_dilated, se);
%     boundary = -V_dilated2+ V_dilated;
%     boundary(boundary > 0) = 1;
%     warped_Atlas = (warped_Atlas).*mask;
%     
%     mask = double(V_dilated==1)*159;
%     boundary = boundary*255;
%     ROI = double(V_dilated2==1)*159;
%     
%     if exist([Warped_CCF_target_path,'CCF_u8_xpad.tif'], 'file') == 2
%         delete([Warped_CCF_target_path,'CCF_u8_xpad.tif']);
%         delete([Warped_CCF_target_path,'CCF_mask.tif']);
%         delete([Warped_CCF_target_path,'CCF_contour.tif']);
%     end
%     
%     temp = make_nii(warped_Atlas);
%     save_nii(temp,[Warped_CCF_target_path,'CCF_u8_xpad.nii.gz'])
%     temp2 = make_nii(double(mask));
%     save_nii(temp2,[Warped_CCF_target_path,'CCF_mask.nii.gz'])
%     temp3 = make_nii(boundary);
%     save_nii(temp3,[Warped_CCF_target_path,'CCF_contour.nii.gz'])
%     temp3 = make_nii(warped_Annotation);
%     save_nii(temp3,[Warped_CCF_target_path,'warped_Annotation.nii.gz'])
%     
%     
%     save([Warped_CCF_target_path,'warped_Atlas.mat'],'warped_Atlas','-v7.3')
%     save([Warped_CCF_target_path,'mask.mat'],'mask','-v7.3')
%     save([Warped_CCF_target_path,'ROI.mat'],'ROI','-v7.3')
%     save([Warped_CCF_target_path,'boundary.mat'],'boundary','-v7.3')
%     save([Warped_CCF_target_path,'warped_Annotation.mat'],'warped_Annotation','-v7.3')
%     disp([Warped_CCF_target_path,' end'])
% 
%     clear V_dilated V_dilated2 temp temp2 temp3
   
    
    
    
    %% Load IMS, stored externally as raw_data
    temp = load_nii([datapath,'\',num2str(reg_resolution),'um\origin\ims_data_',num2str(reg_resolution),'um.nii.gz']);

    if mice_num==310
        temp = load_nii([datapath,'\',num2str(reg_resolution),'um\origin\ims_data_new_cut.nii.gz']);
    end

    ims_data3 = temp.img ;
%     pad_size = 30; % pad 20 pixels per direction
%     ims_data3 = padarray(ims_data3, [pad_size, pad_size, pad_size], 0, 'both');

%     load([datapath,'\',num2str(reg_resolution),'um\origin\ims_data_',num2str(reg_resolution),'um.mat'])
    
    ims_data = permute(ims_data3,[2,1,3]);
    ims_data = permute(ims_data,[1,2,3]);
    ims_data = flip(ims_data,1);
    ims_data = flip(ims_data,3);
    
    ims_data = permute(ims_data,[3,1,2]);
    ims_data = flip(ims_data,2);
    ims_data = flip(ims_data,3);
    
    
    %############################################
%     ims_data = ims_data*4;
%     ims_data(ims_data>255) = 255;
    start_intensity = 800;
    
    %############################################
    
%     mask = ims_data;
%     mask(mask<start_intensity) = 0;
%     ims_data = my_cut_resample_onlyre(1,mask,ims_data);
    ims_data(ims_data<start_intensity) = 0;
    ims_data = uint16(ims_data);
    %---------------153---------------
    % ims_data = myresize(ims_data,floor(size(ims_data)*1.4));
    
    
    figure;imagesc(squeeze(ims_data(100,:,:)))
    figure;imagesc(squeeze(ims_data(100,:,:)>=start_intensity))
    ims_data = uint16(ims_data/10);
    % if exist([mba_path,'ims_data.tif'], 'file') == 2
    %     delete([mba_path,'ims_data.tif']);
    % end
    % 
    % if exist([datapath,'mba\ims_data.tif'], 'file') == 2
    %     delete([datapath,'mba\ims_data.tif']);
    % end
    
    % ims_data = ims_data;
    % save_tif(double(ims_data),  [mba_path,'ims_data.tif']);
    save([mba_path,'ims_data.mat'],'ims_data','-v7.3')
    disp('save ims')

end

