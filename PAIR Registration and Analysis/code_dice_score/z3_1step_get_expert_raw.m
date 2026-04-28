

clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

resolution = 25;
num = 323;
savepath = ['F:\lab\align\xxx\',num2str(num),'\'];
step = 'mba';

%%
clear mask
fname=[savepath,'Score\origin\323_25_origin_Atlas.nii.labels.tif'];
info = imfinfo(fname);
num_images = numel(info); 
for i=1:num_images
    a= imread(fname,i);
    mask(:,:,i)=a;
end
expert_anno = double(permute(mask,[2 1 3]));
temp = make_nii(expert_anno);
save_nii(temp, [savepath,'Score\1step\323_25_origin_Atlas_warped_Expert_Annotation.nii.gz'])

