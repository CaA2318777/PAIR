clear all

addpath D:\v3d_external-master\matlab_io_basicdatatype


for mice_num = 363
reg_resolution = 25;
add_res = 0;

datapath = ['Y:\xxx\xxx\Data\2024\240926_align\',num2str(mice_num),'\',num2str(reg_resolution),'um\'];
traditional_amap = [datapath,'traditional_amap\'];


clear mask
fname=[traditional_amap,'registered_atlas.tiff'];
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

% mask = mask(5:304,5:484,5:179);
temp = make_nii(mask);
save_nii(temp,[traditional_amap,'amap_warped_ims.nii.gz'])

clear mask
fname=[traditional_amap,'amap_Atlas_25um.tiff'];
info = imfinfo(fname);
num_images = numel(info); 
for i=1:num_images
    a= imread(fname,i);
    mask(:,:,i)=a;
end
mask = permute(mask,[2,3,1]);
mask = flip(mask,2);
mask = flip(mask,3);
temp = make_nii(mask);
save_nii(temp,[traditional_amap,'amap_warped_atlas.nii.gz'])

disp(mice_num)
disp('amap end')

end