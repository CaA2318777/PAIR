

clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

resolution = 25;
step1 = 'vm';
step2 = 'ants';
% step2 = 'miracl';
% step2 = 'clearmap';
step2 = 'mba';
% step2 = 'amap';
% step2 = 'mba_global';
% step2 = 'simpleitk';
region = '_big';

for num =  [270]


datapath = ['F:\lab\align\xxx\',num2str(num),'\'];
disp(num)

%%
clear mask
fname=[datapath,'expert_marks\',num2str(num),'_',num2str(resolution),'_','2step_',step1,'_',step2,'_warped_ims.nii.labels---',region(2:end),'.tif'];
info = imfinfo(fname);
num_images = numel(info); 
for i=1:num_images
    a= imread(fname,i);
    mask(:,:,i)=a;
end
expert_anno = double(permute(mask,[2 1 3]));
temp = make_nii(expert_anno);
save_nii(temp, [datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_Expert_Annotation','_','2step_',step1,'_',step2,'_warped_ims',region,'.nii.gz'])

end