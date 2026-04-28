

clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

%--------------------------------
resolution = 25;
BIG = 0;
SMALL = 1;  
SMALL2 = 1;
ADSMALL= 0;

for num =  [270 347 349 363 366 358 269]

    datapath = ['F:\lab\align\xxx\',num2str(num),'\'];
    mkdir([datapath,'dice_score\'])
    temp = load_nii([datapath,'origin_data\',num2str(num),'_',num2str(resolution),'_','origin_Annotation.nii.gz']);
    Annotation = temp.img;


    %%  BIG
    if BIG == 1
        [BIG_Annotation,area_volumn] = get_region_big(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        save([datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','origin_area_volumn.mat'],'area_volumn')
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','origin_BIG_Annotation.nii.gz'])
    end

    %%  SMALL
    if SMALL == 1
        BIG_Annotation = get_region_small(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','origin_SMALL_Annotation.nii.gz'])
    end

    %%  SMALL222
    if SMALL2 == 1
        BIG_Annotation = get_region_small222(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','origin_SMALL222_Annotation.nii.gz'])
    end

    %%  SMALL222
    if ADSMALL == 1
        [BIG_Annotation,area_volumn]  = get_region_adsmall(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        save([datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','origin_adsmall_area_volumn.mat'],'area_volumn')
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','origin_ADSMALL_Annotation.nii.gz'])
    end
end