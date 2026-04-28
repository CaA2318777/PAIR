clear all;
addpath('D:\matlab2021b\toolbox\NIfTI_20140122');

% 参数设置
resolution = 25;
step_type = 'ants';
% step_type = 'clearmap';
% step_type = 'simpleitk';
% step_type = 'miracl';
% step_type = 'mba';
% step_type = 'mba_global';

% step_type = 'ants';
region_type = '_big';
case_numbers =   [316];

for case_num = case_numbers
    % 数据路径设置
    base_path = ['F:\lab\align\xxx\', num2str(case_num), '\'];
    dice_score_dir = [base_path, 'dice_score\'];
    img_output_dir = [base_path, 'img\traditional_', step_type, '\'];
    mat_output_dir = [dice_score_dir, 'mat\'];
    mkdir(img_output_dir);
    mkdir(dice_score_dir);
    mkdir(mat_output_dir);
    
    % 加载数据
    big_annotation_file = [dice_score_dir, num2str(case_num), '_', num2str(resolution), '_origin', upper(region_type), '_Annotation.nii.gz'];
    expert_annotation_file = [dice_score_dir, num2str(case_num), '_', num2str(resolution), '_Expert_Annotation_1step_', step_type, '_warped_ims', region_type, '.nii.gz'];
    warped_image_file = [base_path, 'traditional_result\', num2str(case_num), '_', num2str(resolution), '_1step_', step_type, '_warped_ims.nii.gz'];
    
    BIG_Annotation = load_nii(big_annotation_file).img;
    Expert_Annotation = load_nii(expert_annotation_file).img;
    warped_images = load_nii(warped_image_file).img;

    
%     warped_images =  warped_images(5:5+303,5:5+437,5:5+218);
%     Expert_Annotation = Expert_Annotation(5:5+303,5:5+437,5:5+218);

%     BIG_Annotation = flip(BIG_Annotation,2);
%     warped_images = flip(warped_images,2);
    
    % 设置区域名称
    if strcmp(region_type, '_big')
        region_names = ["HPF", "CTX", "CP", "TH", "HYPO","CortexWM","BS"];
        region_names = ["HPF", "CTX", "CB", "CP", "BS"];
    elseif strcmp(region_type, '_small')
        region_names = ["aco", "act", "fr", "ipn", "mtt"];
    else
        region_names = ["cc", "VL", "fx", "AD", "LGd", "AV", "LGv", "SNr", "NLL", "DCO", "AQ", "VCO", "V4", "LH", "LS"];
    end
    
    if size(Expert_Annotation,2) == 524
        pad_size = [2 2 2]; % 行填充 1，列填充 2
        Expert_Annotation = padarray(Expert_Annotation, pad_size, 0, 'both');
        warped_images = padarray(warped_images, pad_size, 0, 'both');
    end

    if size(Expert_Annotation,2) == 320
        Expert_Annotation = permute(Expert_Annotation,[1,3,2]);
        Expert_Annotation = flip(Expert_Annotation,3);
        Expert_Annotation = flip(Expert_Annotation,2);
    end


    for region_idx = 1:length(region_names)
        region_name = region_names(region_idx);
        region_mask = double(Expert_Annotation == region_idx);
        active_slices = find(squeeze(sum(sum(region_mask, 1), 3)) > 0);
        

        

        % 初始化指标
        dice_scores = zeros(length(active_slices), 1);
        recalls = dice_scores;
        precisions = dice_scores;
        jsc_scores = dice_scores; % 新增 JSC
        
        % 处理每个切片
        for slice_idx = 1:length(active_slices)
            slice_num = active_slices(slice_idx);
            big_slice = squeeze(BIG_Annotation(:, slice_num, :)) == region_idx;
            mask_slice = squeeze(region_mask(:, slice_num, :));
            
            if size(mask_slice,2) == 328
                mask_slice = mask_slice(5:460,5:324);
            end



            recalls(slice_idx) = sum(big_slice(:) .* mask_slice(:)) / sum(mask_slice(:));
            precisions(slice_idx) = sum(big_slice(:) .* mask_slice(:)) / sum(big_slice(:));
            dice_scores(slice_idx) = 2 * recalls(slice_idx) * precisions(slice_idx) / (recalls(slice_idx) + precisions(slice_idx));
            
            % 计算 JSC
            jsc_scores(slice_idx) = sum(big_slice(:) .* mask_slice(:)) / sum(big_slice(:) + mask_slice(:) - big_slice(:) .* mask_slice(:));
            
            % 处理NaN值
            if isnan(dice_scores(slice_idx))
                dice_scores(slice_idx) = 0;
            end
            
            % 绘图
            warped_slice = squeeze(warped_images(:, slice_num, :));
            overlay_image = create_overlay_image(warped_slice, big_slice, mask_slice);

            if(sum(mask_slice(:))) < 10 || (strcmp(region_type, '_big') && dice_scores(slice_idx) < 0.1)
                dice_scores(slice_idx) = -1;
            end

            figure;
            imshow(overlay_image);
            title(sprintf('%d  %s  %s  Slice %d', case_num, char(region_name), step_type, slice_num));
            xlabel(sprintf('R: %.2f  P: %.2f  D: %.2f  J: %.2f', recalls(slice_idx), precisions(slice_idx), dice_scores(slice_idx), jsc_scores(slice_idx)));
            saveas(gcf, fullfile(img_output_dir, sprintf('%d_%d_%s_dice_scores_%s%s_slice%d.png', ...
                case_num, resolution, char(region_name), step_type, region_type, slice_num)));
            
            if(sum(mask_slice(:))) < 10 || (strcmp(region_type, '_big') && dice_scores(slice_idx) < 0.1)
                pause(1)
            end
            close all;
        end


        jsc_scores(dice_scores == -1) = [];
        dice_scores(dice_scores == -1) = [];
        
        
        % 保存结果
        save(fullfile(mat_output_dir, sprintf('%d_%d_%s_dice_scores_%s.mat', case_num, resolution, char(region_name), step_type)), 'dice_scores', 'jsc_scores');
    end
end

function overlay_image = create_overlay_image(base_image, red_mask, blue_mask)
    % 创建叠加的RGB图像
    overlay = zeros(size(base_image, 1), size(base_image, 2), 3);
    overlay(:, :, 1) = red_mask;  % 红色通道
    overlay(:, :, 3) = blue_mask; % 蓝色通道
    
    % 调整方向和翻转
    overlay = uint8(255 * min(max(overlay, 0), 1));
    overlay = permute(overlay, [2, 1, 3]);
    overlay = flip(overlay, 1);
    
    % 旋转基础图像并归一化到 0-255
    base_image_rotated = uint8(255 * mat2gray(imrotate(base_image, 90)));
    
    % 将灰度图像与叠加图合成
    overlay_image = base_image_rotated;
    for c = 1:3
        overlay_image(:, :, c) = base_image_rotated;
    end
    overlay_image = uint8(0.7 * overlay_image + 0.3 * overlay); % 混合两图
end
