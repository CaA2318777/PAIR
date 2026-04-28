clear all
addpath D:\matlab2021b\toolbox\NIfTI_20140122

%--------------------------------
resolution = 25;
step1 = 'vm';
BIG = 0;
SMALL = 0;
SMALL2 = 0;
ADSMALL = 0;
XBL = 1;

% 初始化总体统计
all_cases_total_volume = [];

for num = [419:423]

    datapath = ['F:\lab\align\xxx\',num2str(num),'\'];
    mkdir([datapath,'dice_score\'])
    temp = load_nii([datapath,'pair_atlas\',num2str(num),'_',num2str(resolution),'_','2step_',step1,'_','ants','_warped_Annotation.nii.gz']);
    Annotation = temp.img;
    disp(num)

    % 初始化当前病例的体积数据存储
    case_volume_data = [];

    % 计算每个label的体积
    unique_labels = unique(Annotation(:));
    unique_labels = unique_labels(unique_labels > 0); % 排除背景标签0
    
    for label_idx = 1:length(unique_labels)
        label_value = unique_labels(label_idx);
        label_mask = double(Annotation == label_value);
        volume_mm3 = sum(label_mask(:)) * (resolution * 1e-3)^3; % 转换为mm³
        
        % 获取label名称（从labelmapper中查找）
        try
            load('Y:\xxx\xxx\HD1\altas_dataset\labelmapper.mat')
            if label_value <= length(labelmapper)
                label_name = labelmapper{label_value};
            else
                label_name = sprintf('Unknown_%d', label_value);
            end
        catch
            label_name = sprintf('Label_%d', label_value);
        end
        
        % 添加到当前病例的数据数组
        case_volume_data = [case_volume_data; {label_name, label_value, volume_mm3}];
    end

    % 保存当前病例的体积数据到CSV文件
    if ~isempty(case_volume_data)
        % 创建表头
        headers = {'Label_Name', 'Label_Value', 'Volume_mm3'};
        
        % 创建表格
        volume_table = cell2table(case_volume_data, 'VariableNames', headers);
        
        % 保存到当前病例的CSV文件
        csv_path = [datapath, 'dice_score\volume.csv'];
        writetable(volume_table, csv_path);
        
        % 计算当前病例的总体积
        case_total_volume = sum(cell2mat(case_volume_data(:,3)));
        all_cases_total_volume = [all_cases_total_volume; case_total_volume];
        
        disp(['病例 ', num2str(num), ' 体积数据已保存到: ', csv_path]);
        disp(['病例 ', num2str(num), ' 总共处理了 ', num2str(size(case_volume_data, 1)), ' 个标签']);
        disp(['病例 ', num2str(num), ' 总体积: ', num2str(case_total_volume), ' mm3']);
        
        % 验证当前病例的总体积计算
        total_voxels = sum(Annotation(:) > 0);
        calculated_total_volume = total_voxels * (resolution * 1e-3)^3;
        
        % 检查是否相等
        volume_difference = abs(case_total_volume - calculated_total_volume);
        if volume_difference < 1e-6  % 允许小的数值误差
            disp(['病例 ', num2str(num), ' ✓ 验证通过：所有label体积之和等于总体积']);
        else
            disp(['病例 ', num2str(num), ' ⚠ 验证失败：体积差异为 ', num2str(volume_difference), ' mm3']);
            disp(['病例 ', num2str(num), ' 差异百分比: ', num2str(volume_difference/case_total_volume*100), '%']);
        end
    end

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

     %%  ADSMALL
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

% 显示所有病例的总体积统计
if ~isempty(all_cases_total_volume)
    disp('=== 所有病例总体积统计 ===');
    case_list = [371,372];
    for i = 1:length(case_list)
        disp(['病例 ', num2str(case_list(i)), ' 总体积: ', num2str(all_cases_total_volume(i)), ' mm3']);
    end
    disp(['所有病例平均总体积: ', num2str(mean(all_cases_total_volume)), ' mm3']);
    disp(['所有病例总体积范围: ', num2str(min(all_cases_total_volume)), ' - ', num2str(max(all_cases_total_volume)), ' mm3']);
end 