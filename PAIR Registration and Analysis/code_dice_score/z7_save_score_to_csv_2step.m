clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

resolution = 25;
num = 270.2;
savepath = ['F:\lab\align\xxx\',num2str(num),'\'];
img_path = [savepath,'img\'];
mkdir(img_path)
step1 = 'ants';
step2 = 'ants';

filename = [savepath,num2str(num),'_',num2str(resolution),'_dice_scores_2step_',step1,'_',step2,'.xlsx'];
max_length = 20;
Area_name = {'HPF','CTX','CB','CP','BS'};
all_dice_scores = nan([max_length,length(Area_name)]);

for area_num = 1:5
    load([savepath,num2str(num),'_',num2str(resolution),'_',Area_name{area_num},'_dice_scores_',step1,'-',step2,'.mat'])
    disp(length(dice_scores))
    all_dice_scores(1:length(dice_scores),area_num) = dice_scores;
end


dataTable = array2table(all_dice_scores, 'VariableNames', Area_name);
writetable(dataTable, filename);
