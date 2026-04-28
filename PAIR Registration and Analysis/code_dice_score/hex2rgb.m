function rgb = hex2rgb(hex)
    % 将十六进制颜色转换为 RGB 格式
    hex = char(hex); % 确保输入为字符型
    hex = hex(2:end); % 去掉 "#" 符号
    rgb = reshape(sscanf(hex, '%2x') / 255, 1, 3); % 转换为 RGB 格式并归一化
end