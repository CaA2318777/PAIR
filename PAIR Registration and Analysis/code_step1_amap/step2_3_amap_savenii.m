clear all

addpath D:\v3d_external-master\matlab_io_basicdatatype
for mice_num = [372]
reg_resolution = 25;
add_res = 0;


datapath = ['Y:\xxx\xxx\Data\2024\240926_align\',num2str(mice_num),'\',num2str(reg_resolution),'um\'];
step1_amap_path = [datapath,'step1_amap\'];

disp(mice_num)


clear mask
fname=[step1_amap_path,'registered_atlas.tiff'];
info = imfinfo(fname);
num_images = numel(info); 
for i=1:num_images
    a= imread(fname,i);
    mask(:,:,i)=a;
end
mask = permute(mask,[2,3,1]);
mask = flip(mask,1);
mask = flip(mask,2);
mask = flip(mask,3);
temp = make_nii(mask);
save_nii(temp,[step1_amap_path,'amap_warped_atlas2.nii.gz'])

% clear mask
% fname=[step1_amap_path,'amap_Atlas_25um.tiff'];
% info = imfinfo(fname);
% num_images = numel(info); 
% for i=1:num_images
%     a= imread(fname,i);
%     mask(:,:,i)=a;
% end
% mask = permute(mask,[2,3,1]);
% mask = flip(mask,2);
% mask = flip(mask,3);
% temp = make_nii(mask);
% save_nii(temp,[step1_amap_path,method1,'_amap_warped_atlas.nii.gz'])


end