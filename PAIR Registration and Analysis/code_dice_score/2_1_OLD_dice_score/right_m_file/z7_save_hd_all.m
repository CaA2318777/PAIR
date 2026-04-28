clear all;
addpath('D:\matlab2021b\toolbox\NIfTI_20140122');

% 参数设置
resolution = 25;
case_numbers =   [315,316,317,319,320,321,322,323,324,325,328,333,334];
% methods = {'simpleitk', 'ants_simpleitk', ' '};
% methods = {'clearmap', 'vm_clearmap', ' '};
% methods = {'mba_global', 'ants_mba_global', ' '};
% methods = {'amap', 'ants_amap', ' '};
methods = {'ants', 'vm_ants', ' '};
% methods = {'mba', 'vm_mba', ' '};
region = 'big';
max_entries = 20;

for case_num = case_numbers
    % 路径设置
    base_path = fullfile('F:\lab\align\xxx\', num2str(case_num));
    hd95_score_dir = fullfile(base_path, 'dice_score', 'mat');
    img_output_dir = fullfile(base_path, 'img');
    output_xlsx_dir = fullfile('F:\lab\align\xxx\', [region, '_hd95_xlsx']);
    xlsx_filename = fullfile(base_path, ...
        sprintf('%d_%d_hd95_%s.xlsx', case_num, resolution, region));
    
    % 确保目录存在
    mkdir(img_output_dir);
    mkdir(output_xlsx_dir);
    
    % 删除旧文件（如果存在）
    if exist(xlsx_filename, 'file')
        delete(xlsx_filename);
        fprintf('文件 "%s" 已被成功删除。\n', xlsx_filename);
    else
        fprintf('文件 "%s" 不存在。\n', xlsx_filename);
    end
    
    % 区域名称设置
    if strcmp(region, 'big')
        area_names = {'HPF', 'CTX', 'CP', 'TH', 'HYPO','CortexWM','BS'};
        area_names = {'HPF', 'CTX', 'CB', 'CP', 'BS'};
    elseif strcmp(region, 'small')
        area_names = {'aco', 'act', 'fr', 'ipn', 'mtt'};
    else
        area_names = {'cc', 'VL', 'fx', 'AD', 'LGd', 'AV', 'LGv', 'SNr', ...
                      'NLL', 'DCO', 'AQ', 'VCO', 'V4', 'LH', 'LS'};
    end
    
    % 初始化数据存储
    column_names = {};
    hd95_scores_matrix = nan(max_entries, length(area_names) * length(methods));
    
    % 遍历区域和方法
    for area_idx = 1:length(area_names)
        area_name = area_names{area_idx};
        for method_idx = 1:length(methods)
            method_name = methods{method_idx};
            column_idx = (area_idx - 1) * length(methods) + method_idx;
            
            try
                % 加载对应的 hd95 Scores
                mat_file = fullfile(hd95_score_dir, ...
                    sprintf('%d_%d_%s_HD95_%s.mat', case_num, resolution, area_name, method_name));
                loaded_data = load(mat_file, 'hd95_scores');
                hd95_scores_matrix(1:length(loaded_data.hd95_scores), column_idx) = loaded_data.hd95_scores;
                fprintf('加载成功: %s\n', mat_file);
            catch
                % 加载失败处理
                hd95_scores_matrix(1, column_idx) = -0.01;
                fprintf('   加载失败: %s\n', mat_file);
            end
            
            % 设置列名
            column_names{column_idx} = sprintf('%s %s', method_name, area_name);
        end
    end
    
    % 转换为表格并写入 Excel
    hd95_scores_table = array2table(hd95_scores_matrix, 'VariableNames', column_names);
    writetable(hd95_scores_table, xlsx_filename);
    
    % 备份文件
    backup_xlsx_filename = fullfile(output_xlsx_dir, ...
        sprintf('%d_%d_hd95_%s.xlsx', case_num, resolution, region));
    copyfile(xlsx_filename, backup_xlsx_filename);
end
