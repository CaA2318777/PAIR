function f1_traditional_get_expert(rootpath,nums,step,region)
%F1_TRADITIONAL_GET_EXPERT 此处显示有关此函数的摘要
%   此处显示详细说明

clearvars -except rootpath nums step region
addpath D:\matlab2021b\toolbox\NIfTI_20140122
resolution = 25;
region = ['_',region];


for num = nums

    datapath = [rootpath,num2str(num),'\'];
    disp(num)
    mkdir([datapath,'dice_score\'])
    disp(['traditional_get_expert: ',num2str(num),' ', step,' ',region])
    %%
    clear mask
    fname=[datapath,'expert_marks\',num2str(num),'_',num2str(resolution),'_','1step_',step,'_warped_ims.nii.labels---',region(2:end),'.tif'];
    info = imfinfo(fname);
    num_images = numel(info); 
    for i=1:num_images
        a= imread(fname,i);
        mask(:,:,i)=a;
    end
    expert_anno = double(permute(mask,[2 1 3]));
    temp = make_nii(expert_anno);
    save_nii(temp, [datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_Expert_Annotation','_','1step_',step,'_warped_ims',region, '.nii.gz'])

end



end

