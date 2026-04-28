clear all;
% close all;
addpath('D:\matlab2021b\toolbox\NIfTI_20140122');

% 设置参数
resolution = 25;
case_numbers =  [315,316,317,319,320,321,322,323,324,325,328,333,334];

region = 'big';

for case_num = case_numbers
    % 路径设置
    base_path = fullfile('F:\lab\align\xxx\', num2str(case_num));
    img_output_dir = fullfile(base_path, 'img');
    xlsx_file = fullfile(base_path, ...
        sprintf('%d_%d_hd95_%s.xlsx', case_num, resolution, region));
%     xlsx_file = 'F:\Desktop\column_medians2.xlsx';
    output_img_file = fullfile(img_output_dir, ...
        sprintf('%d_%s_hd95.jpg', case_num, region));
    
    % 确保目录存在
    mkdir(img_output_dir);
    
    % 读取 Excel 数据
    data_table = readtable(xlsx_file, 'PreserveVariableNames', true);
    data = table2array(data_table);
    data(data==-1) = nan;
    column_names = data_table.Properties.VariableNames;
    column_names = strrep(column_names, '_', '-'); % 替换下划线为连字符
    
    % 数据处理：统计区域和方法数量
    area_count = sum(cellfun(@(x) strlength(x) <= 3, column_names));
    if case_num==304
        area_count = 7;
    end
    methods_count = length(column_names) / area_count;
    means = nanmean(data, 1);
    maxs = max(data, [], 1);
    
    % 绘制箱型图
    figure;
    boxplot(data, 'Labels', column_names, 'Whisker', 1.5, 'Colors', 'k');
    set(findobj(gca, 'Type', 'line'), 'LineWidth', 1.5);
    set(findobj(gca, 'Tag', 'Outliers'), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    hold on;
    
    % 自定义颜色设置
    colors = [hex2rgb('#025259'); hex2rgb('#F29325'); hex2rgb('#C08E7A'); hex2rgb('#C08E7A')];
    box_handles = findobj(gca, 'Tag', 'Box');
    for i = 1:length(box_handles)
        method_idx = mod(length(box_handles) - i, methods_count) + 1;
        color = colors(method_idx, :);
        patch('XData', get(box_handles(i), 'XData'), ...
              'YData', get(box_handles(i), 'YData'), ...
              'FaceColor', color, ...
              'FaceAlpha', 0.7, ...
              'EdgeColor', 'k');
    end
    
    
    % 图形样式设置
    xlabel('Methods');
    ylabel('Value');
    title(['Region-wise Median HD95 ', num2str(case_num)]);
    xtickangle(45);
    grid on;
    set(gca, 'FontSize', 12, 'LineWidth', 1.5);
%     ylim([0 1]);
    set(gcf, 'Position', [100, 100, length(column_names) * 50, 600]);
    
    % 添加符号标记
%     symbols = {};
%     marker_colors = {};
%     marked_indices = [];
%     for area_idx = 1:area_count
%         for method_offset = methods_count-1
%             col_idx = (area_idx - 1) * methods_count + method_offset;
%             prev_col_idx = col_idx - 1;
%             marked_indices = [marked_indices, col_idx];
%             
%             if means(col_idx) > means(prev_col_idx)
%                 symbols{end+1} = '✓'; % 对钩
%                 marker_colors{end+1} = 'g';
%             else
%                 symbols{end+1} = 'x'; % 叉号
%                 marker_colors{end+1} = 'r';
%             end
%         end
%     end
    
%     for i = 1:length(marked_indices)
%         idx = marked_indices(i);
%         text(idx, maxs(idx) + 0.02, symbols{i}, ...
%              'Color', marker_colors{i}, 'FontSize', 14, ...
%              'HorizontalAlignment', 'center', 'FontWeight', 'bold');
%     end
    
    % 保存图像
    saveas(gcf, output_img_file);
    backup_img_file = fullfile('F:\lab\align\xxx\', 'img', ...
        sprintf('%d_%s_hd95.jpg', case_num, region));
    saveas(gcf, backup_img_file);
end

% 辅助函数：十六进制颜色转换为 RGB
function rgb = hex2rgb(hex)
    hex = char(hex); % 确保输入为字符型
    hex = hex(2:end); % 去掉 "#" 符号
    rgb = reshape(sscanf(hex, '%2x') / 255, 1, 3); % 转换为 RGB 格式
end
