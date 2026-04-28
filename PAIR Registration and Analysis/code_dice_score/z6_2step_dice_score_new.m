
clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

resolution = 25;
num = 270.2;
savepath = ['F:\lab\align\xxx\',num2str(num),'\'];
img_path = [savepath,'img\'];
mkdir(img_path)
step1 = 'vm';
datapath = ['Y:\xxx\xxx\Data\2024\240926_align\'];


% 人工标注
temp = load_nii([datapath,num2str(num),'\25um\origin\','ims_expert_anno_25um.nii.gz']);
origin_ims_expert_anno = temp.img;

% 图谱对应
temp = load_nii([savepath,num2str(num),'_25_','2step_',step1,'_ants_warped_BIG_Annotation.nii.gz']);
BIG_Annotation = temp.img;

% 人工标注后 变换
temp = load_nii([datapath,num2str(num),'\25um\step2_',step1,'_ants\',step1,'_ants_warped_ims_expert_anno_25um.nii.gz']);
warped_expert_anno = temp.img;

% 人工标注后 层位置
temp = load_nii([datapath,num2str(num),'\25um\step2_',step1,'_ants\',step1,'_ants_warped_ims_expert_anno_number_25um.nii.gz']);
warped_expert_anno_number = temp.img;




Area_name = ["HPF","CTX","CB","CP","BS"];
for area_num = 1:5
    temp = double(origin_ims_expert_anno==area_num);
    temp_num = sum(sum(temp,1),3);
    temp_num = find(temp_num>0);
    
    dice_scores = zeros(length(temp_num),1);
    recall = dice_scores;
    precison = dice_scores;

    temp_warped_expert_anno = double(warped_expert_anno==area_num); % 变换后人工标注的这个脑区
    temp_BIG_Annotation = double(BIG_Annotation==area_num); % atlas的这个脑区

    for i = 1:length(temp_num)
        mask = warped_expert_anno_number*0;
        mask(warped_expert_anno_number==temp_num(i)) = 1;
        
        
        a = temp_warped_expert_anno.*mask; %变换后这一层人工标注的区域
        b = temp_BIG_Annotation.*mask;
        c = a.*b;

        a = sum(a(:));
        b = sum(b(:));
        c = sum(c(:));


        recall(i) =c/a;
        precison(i) = c/b;
        dice_scores(i) = 2*recall(i)*precison(i) / (recall(i)+precison(i)) ;
   
    end
    disp(Area_name(area_num))
    save([savepath,num2str(num),'_',num2str(resolution),'_',char(Area_name(area_num)),'_dice_scores_',step1,'-ants.mat'],'dice_scores');
    close all
end