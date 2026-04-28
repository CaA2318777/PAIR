

clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

%--------------------------------
resolution = 25;
step1 = 'ants';
BIG = 0;
SMALL = 0;
SMALL2 = 0;
ADSMALL = 0;
XBL = 1;

for num = [398,399,401:410]

    datapath = ['F:\lab\align\xxx\',num2str(num),'\'];
    mkdir([datapath,'dice_score\'])
    temp = load_nii([datapath,'pair_atlas\',num2str(num),'_',num2str(resolution),'_','2step_',step1,'_','ants','_warped_Annotation.nii.gz']);
    Annotation = temp.img;
    disp(num)

    %%  BIG
    if BIG == 1
        [BIG_Annotation,area_volumn] = get_region_big(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        disp(area_volumn)
        save([datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','PAIR_',step1,'_area_volumn.mat'],'area_volumn')
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','PAIR_',step1,'_warped_BIG_Annotation.nii.gz'])
    end

    %%  SMALL
    if SMALL == 1
        BIG_Annotation = get_region_small(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','PAIR_',step1,'_warped_SMALL_Annotation.nii.gz'])
    end

    %%  SMALL222
    if SMALL2 == 1
        BIG_Annotation = get_region_small222(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','PAIR_',step1,'_warped_SMALL222_Annotation.nii.gz'])
    end

     %%  SMALL222
    if ADSMALL == 1
        [BIG_Annotation,area_volumn] = get_region_adsmall(Annotation,resolution);
        temp = make_nii(BIG_Annotation);
        disp(area_volumn)
        save([datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','PAIR_',step1,'_adsmall_area_volumn.mat'],'area_volumn')
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','PAIR_',step1,'_warped_ADSMALL_Annotation.nii.gz'])
    end

    %%  XBL
    if XBL == 1
        BIG_Annotation = get_region_xbl(Annotation,resolution,num);
        temp = make_nii(BIG_Annotation);
        save_nii(temp,[datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_','PAIR_',step1,'_warped_XBL_Annotation.nii.gz'])
    end
end