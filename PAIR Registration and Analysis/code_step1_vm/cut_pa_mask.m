clear all

addpath D:/v3d_external-master/matlab_io_basicdatatype



for mice_num = 306

    reg_resolution = 25;
    add_res = 0;
    
    datapath = ['Y:/xxx/xxx/Data/2024/240926_align/',num2str(mice_num),'/', num2str(reg_resolution),'um/'];
    


    temp = load_nii([datapath,'/step1_vm/raw_pa_25.nii.gz']);
    raw_pa = temp.img;
    raw_pa(raw_pa==raw_pa(1,1,1)) = 0;

    temp = load_nii([datapath,'/step1_vm/vm_warped_atlas_25um.nii.gz']);
    warped_atlas = temp.img;

    warped_atlas(raw_pa==0) = 0;
   
    temp = make_nii(warped_atlas);
    save_nii(temp,[datapath,'/step1_vm/vm_warped_atlas_25um_cut.nii.gz'])

end