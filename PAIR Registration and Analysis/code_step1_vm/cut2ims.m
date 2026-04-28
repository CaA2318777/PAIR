clear all

addpath D:/v3d_external-master/matlab_io_basicdatatype
start_frame = 1;



for mice_num = 419

    reg_resolution = 25;
    add_res = 0;
    
    datapath = ['Y:/xxx/xxx/Data/2024/240926_align/',num2str(mice_num),'/', num2str(reg_resolution),'um/'];
    
%% ants
%     if start_frame > 1
%     
%     else
%         %----------------------------------------------------------------
%         temp = load_nii([datapath,'/step1_vm/raw_pa_25.nii.gz']);
%         raw_pa_mask = temp.img;
%         raw_pa_mask(raw_pa_mask~=0) = 1;
%         
%         load([datapath,'/step1_ants/ants_warped_atlas_25um.mat'])
%         load([datapath,'/step1_ants/ants_warped_anno_25um.mat']) 
%         
% %         warped_Atlas = warped_Atlas.*raw_pa_mask;
% %         warped_Annotation = warped_Annotation.*raw_pa_mask;
%     
% 
%         temp = make_nii(warped_Atlas);
%         save_nii(temp,[datapath,'/step1_ants/ants_warped_atlas_25um.nii.gz'])
%         temp = make_nii(warped_Annotation);
%         save_nii(temp,[datapath,'/step1_ants/ants_warped_anno_25um.nii.gz'])
%         %----------------------------------------------------------------
% 
% 
%     end
%     
%     save([datapath,'/step1_ants/start_frame.mat'],'start_frame')


     %% ants  
%     if start_frame > 1
%         temp = load_nii([datapath,'/origin/pa_bg_25um.nii.gz']);
%         raw_pa = temp.img;
%         
%         load([datapath,'/step1_ants/ants_warped_atlas_25um.mat'])
%         load([datapath,'/step1_ants/ants_warped_anno_25um.mat']) 
%         
%         warped_Atlas(:,1:start_frame,:) = 0;
%         warped_Annotation(:,1:start_frame,:) = 0;
%         raw_pa(:,1:start_frame,:) = 0;
%         
% %         save([datapath,'/step1_ants/ants_warped_atlas_25um.mat'],"warped_Atlas")
% %         save([datapath,'/step1_ants/ants_warped_anno_25um.mat'],"warped_Annotation")
% %         save([datapath,'/step1_ants/ants_origin_pa_25um.mat'],"raw_pa")
%         
%         temp = make_nii(raw_pa);
%         save_nii(temp,[datapath,'/step1_ants/ants_origin_pa_25um.nii.gz'])
%         temp = make_nii(warped_Atlas);
%         save_nii(temp,[datapath,'/step1_ants/ants_warped_atlas_25um.nii.gz'])
%         temp = make_nii(warped_Annotation);
%         save_nii(temp,[datapath,'/step1_ants/ants_warped_anno_25um.nii.gz'])
% %     
% %     else
% %         copyfile([datapath,'/step1_ants/ants_warped_atlas_25um_unmask.nii.gz'],[datapath,'/step1_ants/ants_warped_atlas_25um.nii.gz'])
% %         copyfile([datapath,'/step1_ants/ants_warped_anno_25um_unmask.nii.gz'],[datapath,'/step1_ants/ants_warped_anno_25um.nii.gz'])
%     end
% %     
%     save([datapath,'/step1_ants/start_frame.mat'],'start_frame')


    %% vm
    if start_frame > 1
        temp = load_nii([datapath,'/step1_vm/raw_pa_25.nii.gz']);
        raw_pa = temp.img;
        
        load([datapath,'/step1_vm/vm_warped_atlas_25um_unmask.mat'])
        load([datapath,'/step1_vm/vm_warped_anno_25um_unmask.mat']) 
        
        warped_Atlas(:,1:start_frame,:) = 0;
        warped_Annotation(:,1:start_frame,:) = 0;
        raw_pa(:,1:start_frame,:) = 0;
        
        save([datapath,'/step1_vm/vm_warped_atlas_25um.mat'],"warped_Atlas")
        save([datapath,'/step1_vm/vm_warped_anno_25um.mat'],"warped_Annotation")
        save([datapath,'/step1_vm/vm_origin_pa_25um.mat'],"raw_pa")
        
        temp = make_nii(raw_pa);
        save_nii(temp,[datapath,'/step1_vm/vm_origin_pa_25um.nii.gz'])
        temp = make_nii(warped_Atlas);
        save_nii(temp,[datapath,'/step1_vm/vm_warped_atlas_25um.nii.gz'])
        temp = make_nii(warped_Annotation);
        save_nii(temp,[datapath,'/step1_vm/vm_warped_anno_25um.nii.gz'])
    
    else
        %----------------------------------------------------------------
%         temp = load_nii([datapath,'/step1_vm/raw_pa_25.nii.gz']);
%         raw_pa_mask = temp.img;
%         raw_pa_mask(raw_pa_mask~=0) = 1;
%         
%         load([datapath,'/step1_vm/vm_warped_atlas_25um_unmask.mat'])
%         load([datapath,'/step1_vm/vm_warped_anno_25um_unmask.mat']) 
%         
%         warped_Atlas = warped_Atlas.*raw_pa_mask;
%         warped_Annotation = warped_Annotation.*raw_pa_mask;
%         
%         save([datapath,'/step1_vm/vm_warped_atlas_25um.mat'],"warped_Atlas")
%         save([datapath,'/step1_vm/vm_warped_anno_25um.mat'],"warped_Annotation")
% 
%         temp = make_nii(warped_Atlas);
%         save_nii(temp,[datapath,'/step1_vm/vm_warped_atlas_25um.nii.gz'])
%         temp = make_nii(warped_Annotation);
%         save_nii(temp,[datapath,'/step1_vm/vm_warped_anno_25um.nii.gz'])
        %----------------------------------------------------------------

%         copyfile([datapath,'/step1_vm/raw_pa_25.nii.gz'],[datapath,'/step1_vm/vm_origin_pa_25um.nii.gz'])
        copyfile([datapath,'/step1_vm/vm_warped_atlas_25um_unmask.nii.gz'],[datapath,'/step1_vm/vm_warped_atlas_25um.nii.gz'])
        copyfile([datapath,'/step1_vm/vm_warped_anno_25um_unmask.nii.gz'],[datapath,'/step1_vm/vm_warped_anno_25um.nii.gz'])
    end
    
    save([datapath,'/step1_vm/start_frame.mat'],'start_frame')

end