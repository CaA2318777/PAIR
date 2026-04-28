clear all;
addpath('D:\matlab2021b\toolbox\NIfTI_20140122');

% 参数设置
resolution = 25;
step1 = 'vm';

for sss = {'mba','mba_global','simpleitk','ants', 'clearmap','amap'}
    step2 = sss{1}; 
    region_type = '_big';
    case_numbers = [323,324,325,328,333,334]; %315,316,317,319,320,321,322,
    
    for case_num = case_numbers
        % 数据路径设置
        base_path = ['F:\lab\align\xxx\', num2str(case_num), '\'];
        dice_score_dir = [base_path, 'dice_score\'];
        img_output_dir = [base_path, 'img\PAIR_', step1, '_', step2, '\'];
        mat_output_dir = [dice_score_dir, 'mat\'];
        mkdir(img_output_dir);
        mkdir(dice_score_dir);
        mkdir(mat_output_dir);
        
        % 加载数据
        big_annotation_file = [dice_score_dir, num2str(case_num), '_', num2str(resolution), '_PAIR_', step1, '_warped', upper(region_type), '_Annotation.nii.gz'];
        expert_annotation_file = [dice_score_dir, num2str(case_num), '_', num2str(resolution), '_Expert_Annotation_2step_', step1, '_', step2, '_warped_ims', region_type, '.nii.gz'];
        warped_image_file = [base_path, 'pair_result\', num2str(case_num), '_', num2str(resolution), '_2step_', step1, '_', step2, '_warped_ims.nii.gz'];
        
        if ~(exist(expert_annotation_file, 'file'))
            disp(['no ',num2str(case_num),' ',step2])
            continue
        end

        BIG_Annotation = load_nii(big_annotation_file).img;
        Expert_Annotation = load_nii(expert_annotation_file).img;
        warped_images = load_nii(warped_image_file).img;
        
        % 图像预处理（如果需要）
        if size(Expert_Annotation,3) == 628
            Expert_Annotation = permute(Expert_Annotation,[1,3,2]);
            Expert_Annotation = flip(Expert_Annotation,3);
            Expert_Annotation = flip(Expert_Annotation,2);
            Expert_Annotation = flip(Expert_Annotation,1);
        end

        % disp(size(BIG_Annotation,3))
        % disp(size(Expert_Annotation,3))
        % disp(size(warped_images,3))
        if size(BIG_Annotation,3) - size(Expert_Annotation,3) == -4
            Expert_Annotation = Expert_Annotation(3:size(Expert_Annotation,1)-2,3:size(Expert_Annotation,2)-2,3:size(Expert_Annotation,3)-2);
            % warped_images = warped_images(3:size(warped_images,1)-2,3:size(warped_images,2)-2,3:size(warped_images,3)-2);
        end
        % BIG_Annotation = flip(BIG_Annotation, 2);
        % warped_images = flip(warped_images, 2);
        
        % 设置区域名称
        if strcmp(region_type, '_big')
            region_names = ["HPF", "CTX", "CB", "CP", "BS"];
        elseif strcmp(region_type, '_small')
            region_names = ["aco", "act", "fr", "ipn", "mtt"];
        else
            region_names = ["cc", "VL", "fx", "AD", "LGd", "AV", "LGv", "SNr", "NLL", "DCO", "AQ", "VCO", "V4", "LH", "LS"];
        end
        
    % ...（前面参数设置和路径配置保持不变）
    
        % 遍历区域
        for region_idx = 1:length(region_names)
            region_name = region_names(region_idx);
            
            % 检查mat文件是否已存在
            mat_file_path = fullfile(mat_output_dir, sprintf('%d_%d_%s_HD95_%s_%s.mat', case_num, resolution, char(region_name), step1, step2));
            if exist(mat_file_path, 'file')
                disp(['跳过 ', num2str(case_num), ' ', step1, '_', step2, ' ', char(region_name), ' - 文件已存在']);
                continue;
            end
            
            region_mask = double(Expert_Annotation == region_idx);
            active_slices = find(squeeze(sum(sum(region_mask, 1), 3)) > 0);
            
            % 初始化指标
            hd95_scores = zeros(length(active_slices), 1); % 替换dice_scores为hd95
            
            % 处理每个切片
            for slice_idx = 1:length(active_slices)
                slice_num = active_slices(slice_idx);
                big_slice = squeeze(BIG_Annotation(:, slice_num, :)) == region_idx;
                mask_slice = squeeze(region_mask(:, slice_num, :));
                
                % 提取边界点
                big_boundary = bwperim(big_slice);
                mask_boundary = bwperim(mask_slice);
                
                % 计算双向距离
                if any(big_boundary(:)) && any(mask_boundary(:))
                    % 计算big到mask的距离
                    dist_big2mask = bwdist(mask_boundary);
                    distances_b2m = dist_big2mask(big_boundary);
                    
                    % 计算mask到big的距离
                    dist_mask2big = bwdist(big_boundary);
                    distances_m2b = dist_mask2big(mask_boundary);
                    
                    % 合并距离并计算95th percentile
                    all_distances = [distances_b2m; distances_m2b];
                    hd95 = prctile(all_distances, 95);
                else
                    hd95 = -1; % 标记无效切片
                end
                
                % 处理无效值
                if isnan(hd95) || isinf(hd95)
                    hd95 = -1;
                end
                
                % 过滤无效切片
                if sum(mask_slice(:)) < 10 || hd95 == -1
                    hd95 = -1;
                end
                
                hd95_scores(slice_idx) = hd95;
                
                % 生成并保存叠加图像（更新显示指标）
                warped_slice = squeeze(warped_images(:, slice_num, :));
                overlay_image = create_overlay_image(warped_slice, big_slice, mask_slice);
                
                figure;
                imshow(overlay_image);
                title(sprintf('%d  %s  %s_%s  Slice %d', case_num, char(region_name), step1, step2, slice_num));
                xlabel(sprintf('HD95: %.2f um', hd95*resolution)); % 修改显示指标
                saveas(gcf, fullfile(img_output_dir, sprintf('%d_%d_%s_HD95_%s_%s%s_slice%d.png',... % 修改文件名
                    case_num, resolution, char(region_name), step1, step2, region_type, slice_num)));
                close all;
            end
            
            % 过滤无效分数
            valid_scores = hd95_scores ~= -1;
            hd95_scores = hd95_scores(valid_scores);
            hd95_scores = hd95_scores*resolution;
            % 保存结果（更新变量名）
            save(fullfile(mat_output_dir, sprintf('%d_%d_%s_HD95_%s_%s.mat',...
                case_num, resolution, char(region_name), step1, step2)), 'hd95_scores');
        end
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
    
    % 旋转基础图像并归一化
    base_image_rotated = uint8(255 * mat2gray(imrotate(base_image, 90)));
    
    % 合成最终图像
    overlay_image = repmat(base_image_rotated, [1, 1, 3]);
    overlay_image = uint8(0.7 * overlay_image + 0.3 * overlay);
end