clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

resolution = 25;

step1 = 'vm';
% step2 = 'ants';
% step2 = 'amap';
step2 = 'mba_global';
case_numbers =   [310];
region = '_big';

for num = case_numbers

    datapath = ['F:\lab\align\xxx\',num2str(num),'\'];
    dice_score_path = [datapath,'dice_score\'];
    img_path = [datapath,'img\PAIR_',step1,'_',step2,'\'];
    mat_path = [dice_score_path,'mat\'];
    mkdir(img_path)
    mkdir(dice_score_path)
    mkdir(mat_path)
    
    temp = load_nii([dice_score_path,num2str(num),'_',num2str(resolution),'_PAIR_',step1,'_warped',upper(region),'_Annotation.nii.gz']);
    BIG_Annotation = temp.img;
    temp = load_nii([datapath,'dice_score\',num2str(num),'_',num2str(resolution),'_Expert_Annotation','_','2step_',step1,'_',step2,'_warped_ims',region, '.nii.gz']);
    Expert_Annotation = temp.img;
    temp = load_nii([datapath,'pair_result\',num2str(num),'_',num2str(resolution),'_','2step_',step1,'_',step2,'_warped_ims.nii.gz']);
    warped_ims = temp.img;
    
    if strcmp(region,'_big')
        Area_name = ["HPF","CTX","CB","CP","BS"];
    elseif strcmp(region,'_small')
        Area_name = ["aco","act","fr","ipn","mtt"];
    else
        Area_name = ["cc","VL","fx","AD","LGd","AV","LGv","SNr","NLL","DCO","AQ","VCO","V4","LH","LS"]; 
    end
    
    for area_num = 1:length(Area_name)
        mask = double(Expert_Annotation==area_num);
        temp_num = sum(sum(mask,1),3);
        temp_num = find(temp_num>0);
        
        dice_scores = zeros(length(temp_num),1);
        recall = dice_scores;
        precision = dice_scores;
        jsc_scores = dice_scores;
        
        for i = 1:length(temp_num)
            all_temp = squeeze(BIG_Annotation(:,temp_num(i),:));
            all_temp = double(all_temp==area_num);
            mask_temp = squeeze(mask(:,temp_num(i),:));
            
            intersection = sum(sum(all_temp.*mask_temp));
            union = sum(sum(all_temp | mask_temp));
            
            recall(i) = intersection / sum(mask_temp(:));
            precision(i) = intersection / sum(all_temp(:));
            dice_scores(i) = 2 * recall(i) * precision(i) / (recall(i) + precision(i));
            jsc_scores(i) = intersection / union;
            
            if isnan(dice_scores(i))
                dice_scores(i) = 0;
            end
            
            if sum(mask_temp(:)) < 10 || (strcmp(region, '_big') && dice_scores(i) < 0.1)
                dice_scores(i) = -1;
                jsc_scores(i) = -1;
            end
            
            data_temp = squeeze(warped_ims(:,temp_num(i),:));
            data_temp2 = imrotate(data_temp,90);
            

            data_temp = imresize(data_temp, (size(data_temp)*4), 'nearest');
            all_temp = imresize(data_temp, (size(data_temp)*4), 'bilinear');
            mask_temp = imresize(data_temp, (size(data_temp)*4), 'bilinear');


            % Display grayscale image
            figure;
            imagesc(data_temp2);
            colormap(gray);
            colorbar;
            hold on;
            
            % Create RGB overlay
            all_temp = edge(all_temp, 'Canny');
            overlay = zeros(size(data_temp, 1)*4, size(data_temp, 2)*4, 3);
            overlay(:,:,1) = overlay(:,:,1) + all_temp;
            overlay(:,:,3) = overlay(:,:,3) + mask_temp;
            overlay = min(max(overlay, 0), 1);
            overlay = permute(overlay,[2,1,3]);
            overlay = flip(overlay,1);
            overlay = uint8(255 * overlay);
            
            h = imshow(overlay);
            set(h, 'AlphaData', 0.3);
            axis off;
            axis image
            title([num2str(num),'  ',char(Area_name(area_num)),'  ',step1,'_',step2,'  slice',num2str(temp_num(i))]);
            xlabel([' R:',num2str(recall(i)),'   P:',num2str(precision(i)),'   D:',num2str(dice_scores(i)),'   J:',num2str(jsc_scores(i))]);
            colorbar off;
            
            % Save the image
%             saveas(gcf, [img_path,num2str(num),'_',num2str(resolution),'_',char(Area_name(area_num)),'_dice_scores_',step1,'_',step2,region,'_slice',num2str(temp_num(i)),'.png']);
        end
        

    end 
end
