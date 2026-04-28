
clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

resolution = 25;
num = 323;
savepath = ['F:\lab\align\xxx\',num2str(num),'\'];
img_path = [savepath,'img\'];
mkdir(img_path)


temp = load_nii([savepath,num2str(num),'_',num2str(resolution),'_','origin_BIG_Annotation.nii.gz']);
BIG_Annotation = temp.img;
temp = load_nii( [savepath,'Score\1step\323_25_origin_Atlas_warped_Expert_Annotation.nii.gz']);
Expert_Annotation = temp.img;
temp = load_nii([savepath,num2str(num),'_',num2str(resolution),'_origin_Atlas.nii.gz']);
warped_ims = temp.img;



Area_name = ["HPF","CTX","CB","CP","BS"];
for area_num = 1:5
    mask = double(Expert_Annotation==area_num);
    temp_num = sum(sum(mask,1),3);
    temp_num = find(temp_num>0);
    
    dice_scores = zeros(length(temp_num),1);
    recall = dice_scores;
    precison = dice_scores;
    for i = 1:length(temp_num)
        all_temp = squeeze(BIG_Annotation(:,temp_num(i),:));
        all_temp = double(all_temp==area_num);
        mask_temp = squeeze(mask(:,temp_num(i),:));
        recall(i) = sum(sum(all_temp.*mask_temp))/sum(mask_temp(:));
        precison(i) = sum(sum(all_temp.*mask_temp))/sum(all_temp(:));
        dice_scores(i) = 2*recall(i)*precison(i) / (recall(i)+precison(i)) ;
    
        data_temp = squeeze(warped_ims(:,temp_num(i),:));
        data_temp2 = imrotate(data_temp,90);
%         data_temp = permute(data_temp,[2,1,3]);
%         data_temp = flip(data_temp,1);
%         data_temp = flip(data_temp,2);
    
        % 使用imagesc显示灰度图像
        figure;
        imagesc(data_temp2);
        colormap(gray);
        colorbar; % 显示颜色条
        hold on; % 保持当前图像以便在其上绘制其他元素
        
        % 创建一个与data_temp相同大小的三通道RGB图像，初始化为全零（即透明）
        overlay = zeros(size(data_temp, 1), size(data_temp, 2), 3);
        overlay(:,:,1) = overlay(:,:,1) + all_temp;
        overlay(:,:,3) = overlay(:,:,3) + mask_temp;
        
        % 确保颜色值在合理范围内并转换数据类型
        overlay = min(max(overlay, 0), 1); % 限制颜色值在0到1之间
        overlay = permute(overlay,[2,1,3]);
        overlay = flip(overlay,1);
%         overlay = flip(overlay,2);
        overlay = uint8(255 * overlay); % 转换为0-255的范围以便显示
        

        % 使用imshow显示叠加后的图像，注意不需要再调整AlphaData，因为这里我们直接操作了颜色值
        h = imshow(overlay);
    
        % 设置叠加层的alpha（透明度），可以根据需要调整
        set(h, 'AlphaData', 0.3); % 示例中设置为半透明
        axis off;
        title([num2str(num),'  ',char(Area_name(area_num)),'  Atlas  slice',num2str(temp_num(i))])
        xlabel([' R:',num2str(recall(i)),'   P:',num2str(precison(i)),'   D:',num2str(dice_scores(i))] )
        colorbar off
        
        % 保存图像
        saveas(gcf, [img_path,num2str(num),'_',num2str(resolution),'_atlas_',char(Area_name(area_num)),'_dice_scores_slice',num2str(temp_num(i)),'.png']); % 保存为PNG文件，也可以选择其他格式
    end
    save([savepath,'Atlas',num2str(num),'_',num2str(resolution),'_',char(Area_name(area_num)),'_dice_scores.mat'],'dice_scores');
    close all
end