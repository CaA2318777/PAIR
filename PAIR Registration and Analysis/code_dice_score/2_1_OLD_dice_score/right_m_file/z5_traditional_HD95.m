clear all;
addpath('D:\matlab2021b\toolbox\NIfTI_20140122');

% 参数设置
resolution = 25;
step_types = {'mba', 'ants', 'mba_global', 'amap', 'clearmap', 'simpleitk'};
region_type = '_big';
case_numbers = [323,324,325,328,333,334];%315,316,317,319,320,321,322,

for case_num = case_numbers
    % 数据路径设置
    base_path = ['F:\lab\align\xxx\', num2str(case_num), '\'];
    hd95_score_dir = [base_path, 'dice_score\']; % 修改目录名称
    mat_output_dir = [hd95_score_dir, 'mat\']; % 修改mat目录路径
    mkdir(hd95_score_dir); % 创建HD95目录
    mkdir(mat_output_dir);
    
    % 加载数据
    big_annotation_file = [hd95_score_dir, num2str(case_num), '_', num2str(resolution), '_origin', upper(region_type), '_Annotation.nii.gz'];
    
    if ~(exist(big_annotation_file, 'file'))
        disp(['no big annotation file for case ', num2str(case_num)])
        continue
    end
    
    BIG_Annotation = load_nii(big_annotation_file).img;
    
    % 遍历step_type
    for step_idx = 1:length(step_types)
        step_type = step_types{step_idx};
        
        % 为每个step_type创建输出目录
        img_output_dir = [base_path, 'img\traditional_', step_type, '\'];
        mkdir(img_output_dir);
        
        % 加载对应step_type的数据
        expert_annotation_file = [hd95_score_dir, num2str(case_num), '_', num2str(resolution), '_Expert_Annotation_1step_', step_type, '_warped_ims', region_type, '.nii.gz'];
        warped_image_file = [base_path, 'traditional_result\', num2str(case_num), '_', num2str(resolution), '_1step_', step_type, '_warped_ims.nii.gz'];
        
        if ~(exist(expert_annotation_file, 'file'))
            disp(['no ',num2str(case_num),' ',step_type])
            continue
        end
        
        Expert_Annotation = load_nii(expert_annotation_file).img;
        warped_images = load_nii(warped_image_file).img;

        if size(Expert_Annotation,3) == 528
            Expert_Annotation = permute(Expert_Annotation,[1,3,2]);
            Expert_Annotation = flip(Expert_Annotation,3);
            Expert_Annotation = flip(Expert_Annotation,2);
        end

%         warped_images = warped_images(5:5+303,5:5+437,5:5+218);
%         Expert_Annotation = Expert_Annotation(5:5+303,5:5+437,5:5+218);

        % 设置区域名称
        if strcmp(region_type, '_big')
            region_names = ["HPF", "CTX", "CB", "CP", "BS"];
        elseif strcmp(region_type, '_small')
            region_names = ["aco", "act", "fr", "ipn", "mtt"];
        else
            region_names = ["cc", "VL", "fx", "AD", "LGd", "AV", "LGv", "SNr", "NLL", "DCO", "AQ", "VCO", "V4", "LH", "LS"];
        end
        
        % 遍历区域
        for region_idx = 1:length(region_names)
            region_name = region_names(region_idx);
            
            % 检查mat文件是否已存在
            mat_file_path = fullfile(mat_output_dir, sprintf('%d_%d_%s_HD95_%s.mat', case_num, resolution, char(region_name), step_type));
            if exist(mat_file_path, 'file')
                disp(['跳过 ', num2str(case_num), ' ', step_type, ' ', char(region_name), ' - 文件已存在']);
                continue;
            end
            
            region_mask = double(Expert_Annotation == region_idx);
            active_slices = find(squeeze(sum(sum(region_mask, 1), 3) > 0));
            
            % 初始化指标
            hd95_scores = zeros(length(active_slices), 1); % 替换为HD95
            
            % 处理每个切片
            for slice_idx = 1:length(active_slices)
                slice_num = active_slices(slice_idx);
                big_slice = squeeze(BIG_Annotation(:, slice_num, :)) == region_idx;
                mask_slice = squeeze(region_mask(:, slice_num, :));
                
                % 提取边界
                big_boundary = bwperim(big_slice);
                mask_boundary = bwperim(mask_slice);
                
                % 计算HD95
                if any(big_boundary(:)) && any(mask_boundary(:))
                    % 双向距离计算
                    dist_big2mask = bwdist(mask_boundary);
                    distances_b2m = dist_big2mask(big_boundary);
                    
                    dist_mask2big = bwdist(big_boundary);
                    distances_m2b = dist_mask2big(mask_boundary);
                    
                    % 合并距离并取95th percentile
                    all_distances = [distances_b2m; distances_m2b];
                    hd95 = prctile(all_distances, 95);
                else
                    hd95 = -1; % 无效标记
                end
                
                % 处理无效值
                if isnan(hd95) || isinf(hd95)
                    hd95 = -1;
                end
                
                % 过滤条件调整
                if sum(mask_slice(:)) < 10 || hd95 == -1
                    hd95 = -1;
                end
                
                hd95_scores(slice_idx) = hd95;
                
                % 生成并保存叠加图像
                warped_slice = squeeze(warped_images(:, slice_num, :));
                overlay_image = create_overlay_image(warped_slice, big_slice, mask_slice);

                figure;
                imshow(overlay_image);
                title(sprintf('%d  %s  %s  Slice %d', case_num, char(region_name), step_type, slice_num));
                xlabel(sprintf('HD95: %.2f um', hd95*resolution)); % 修改显示指标
                saveas(gcf, fullfile(img_output_dir, sprintf('%d_%d_%s_HD95_%s%s_slice%d.png', ...
                    case_num, resolution, char(region_name), step_type, region_type, slice_num)));
                
                close all;
            end

            % 过滤无效分数
            valid_scores = hd95_scores ~= -1;
            hd95_scores = hd95_scores(valid_scores);
            hd95_scores = hd95_scores*resolution;
            % 保存结果
            save(fullfile(mat_output_dir, sprintf('%d_%d_%s_HD95_%s.mat', case_num, resolution, char(region_name), step_type)), 'hd95_scores');
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