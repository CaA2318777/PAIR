
region = 'big';

% 文件夹路径和输出文件名
inputFolder = ['F:\lab\align\xxx\',region,'_old_xlsx\']; % 替换为存放 xlsx 文件的文件夹路径
fileList = dir(fullfile(inputFolder, ['*',region,'.xlsx']));

% 初始化存储数据的变量
allData = [];
allHeaders = {};

% 遍历每个文件
for num = [269,270,363,366,347,349,358]
    % 获取当前文件路径
    filePath = [inputFolder, num2str(num),'_',num2str(25),'_dice_scores_old_',region,'.xlsx'];
    
    % 读取当前文件的数据（假设数据范围不大，直接用 readtable）
    tbl = readtable(filePath,'PreserveVariableNames', true);
    
    % 提取标题（第一行）和数据
    headers = tbl.Properties.VariableNames; % 获取列标题
    data = table2array(tbl); % 转为矩阵
    
    % 将标题和数据存储
    if isempty(allHeaders)
        allHeaders = headers; % 第一个文件的标题作为总标题
    end
    
    % 检查标题一致性（可选步骤）
    if ~isequal(headers, allHeaders)
        warning('文件 %s 的列标题与其他文件不一致！', fileList(i).name);
    end
    
    % 追加数据
    allData = [allData; data]; % 按行追加
end

% 创建输出表
outputTable = array2table(allData, 'VariableNames', allHeaders);
outputFile = [inputFolder,'all.xlsx'];
if exist(outputFile, 'file')
    delete(outputFile);
    fprintf('文件 "%s" 已被成功删除。\n', outputFile);
else
    fprintf('文件 "%s" 不存在。\n', outputFile);
end

% 保存整合后的数据
writetable(outputTable, outputFile);
fprintf('数据整合完成，已保存到 %s\n', outputFile);









%%

% 读取 Excel 数据
fileName = outputFile;

dataTable = readtable(fileName,'PreserveVariableNames', true); % 使用 readtable 读取数据表格
data = table2array(dataTable);  % 将数据转换为数组
columnNames = dataTable.Properties.VariableNames; % 获取列名
columnNames = strrep(columnNames, '_', '-'); % 将下划线替换为连字符
% columnNames = regexprep(columnNames, '([A-Z])', ' $1'); % 在每个大写字母前添加空格

data(isnan(data)) = NaN; % 确保空单元格被标记为 NaN

area_num = 0;
for i = 1:length(columnNames)
    if strlength(columnNames{i}) <= 4
        area_num = area_num+1;
        columnNames{i} = ' '; % 替换为单个空格
    end
end


% 初始化
[numRows, numCols] = size(data); % 获取行列数
means = nan(1, numCols);        % 存储每列均值
stds = nan(1, numCols);         % 存储每列标准差

% 计算均值和标准差（忽略 NaN）
for i = 1:numCols
    columnData = data(:, i);     % 提取每列数据
    columnData = columnData(~isnan(columnData)); % 去除 NaN
    if ~isempty(columnData)
        means(i) = mean(columnData); % 计算均值
        stds(i) = std(columnData);   % 计算标准差
    end
end
methods_num = length(columnNames)/area_num;
% 绘制柱状图
figure;
b = bar(means, 'FaceColor', 'flat', 'EdgeColor', 'k'); % 设置为 flat 模式，允许单独修改颜色
hold on;

    % 修改柱子的颜色
    for i = 1:numCols
        if mod(i, methods_num) == 1
            b.CData(i, :) = hex2rgb('#A9A9A9'); 
        elseif  mod(i, methods_num) == 2
            b.CData(i, :) = hex2rgb('#E6C8AA') ; 
        else
            b.CData(i, :) = hex2rgb('#C08E7A') ; 
        end
    end

% 添加误差条
errorbar(1:numCols, means, stds, 'k.', 'LineWidth', 1.5); % 误差条

% 设置图形样式
xlabel('Methods');
ylabel('Value');
title('Bar Plot with Error Bars');
xticks(1:numCols);
xticklabels(columnNames); % 设置 x 轴刻度标签为列名
xtickangle(45); % 旋转 x 轴标签以避免重叠
grid on;

title(['oldmark ',' ',region])

% 调整图形窗口大小
set(gcf,  'Position', [100, 100,length(columnNames)*50, 600]); % 窗口大小调整
set(gca, 'FontSize', 12, 'LineWidth', 1.5); % 坐标轴样式
ylim([0,1])



% 在柱状图中标记特定的柱子
    symbols = {}; % 使用对钩和叉号的符号
    markerColors = {};
    
    aaa = 0;
    markedBars = zeros(floor(methods_num/3)*area_num);
    for iii=methods_num-1:methods_num-1:methods_num
        for kkk = 1:area_num
            aaa = aaa+1;
            markedBars(aaa) = (kkk-1)*methods_num+iii;
            if means((kkk-1)*methods_num+iii) > means((kkk-1)*methods_num+iii-1)  
                symbols{aaa} = '✓';
                markerColors{aaa} = 'g';
            else
                symbols{aaa} = '×';
                markerColors{aaa} = 'r';
            end
        end
    end

    
    for i = 1:length(markedBars)
        barIndex = markedBars(i);
        text(barIndex, means(barIndex) + stds(barIndex) + 0.02, ... % 确保符号在柱子顶部
             symbols{i}, 'Color', markerColors{i}, 'FontSize', 14, ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end


    
saveas(gcf,[inputFolder,'oldmark.jpg'])

function rgb = hex2rgb(hex)
    % 将十六进制颜色转换为 RGB 格式
    hex = char(hex); % 确保输入为字符型
    hex = hex(2:end); % 去掉 "#" 符号
    rgb = reshape(sscanf(hex, '%2x') / 255, 1, 3); % 转换为 RGB 格式并归一化
end