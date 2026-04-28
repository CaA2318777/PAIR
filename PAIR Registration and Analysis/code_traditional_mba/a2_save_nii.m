resolution = 25;
for num = [358,359,360,361,363]

line1 = ['D:/anaconda3/envs/seg/python.exe '];
line2 = ['Y:/xxx/xxx/xxx/2024/240926_new_align/code_traditional_mba/read_v3draw.py']
line3 = [' -r ' , num2str(resolution) , ' -num ' , num2str(num)];

line = [line1,line2,line3];
[status, cmdout] = system(line);

% 显示命令执行状态
disp(['命令执行状态: ', num2str(status)]);

% 显示命令输出
disp(['命令输出: ', cmdout]);
disp(num)
end 