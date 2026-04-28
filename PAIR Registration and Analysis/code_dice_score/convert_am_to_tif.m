function convert_am_to_tif(amFilePath, tifFilePath)
    % 打开 .am 文件
    fid = fopen(amFilePath, 'rb');
    if fid == -1
        error('无法打开文件: %s', amFilePath);
    end

    % 读取文件内容
    header = '';
    while true
        line = fgetl(fid);
        if isempty(line) || line(1) == '@'
            break; % 到达数据部分或结束文件头
        end
        header = [header, line, newline]; %#ok<AGROW>
    end
    
    % 提取网格尺寸
    dims = regexp(header, 'define Lattice (\d+) (\d+) (\d+)', 'tokens', 'once');
    if isempty(dims)
        fclose(fid);
        error('无法找到网格尺寸信息！');
    end
    dims = str2double(dims); % 转换为数值数组

    % 检查数据类型
    dataType = regexp(header, 'Lattice \{ (\w+) Labels \}', 'tokens', 'once');
    if isempty(dataType)
        fclose(fid);
        error('无法找到数据类型信息！');
    end
    dataType = dataType{1};

    % 定位数据部分
    dataPos = ftell(fid); % 获取当前文件位置（即数据部分起始位置）

    % 解压或直接读取数据
    if contains(header, 'HxByteRLE')
        % RLE 压缩，需要解压
        error('HxByteRLE 格式暂不支持，请使用其他工具解压数据。');
    else
        % 无压缩，直接读取数据
        fseek(fid, dataPos, 'bof');
        rawData = fread(fid, prod(dims), ['*' dataType]);
    end

    % 关闭文件
    fclose(fid);

    % 调整数据维度
    volumeData = reshape(rawData, dims');
    volumeData = permute(volumeData, [2, 1, 3]); % 转置 X 和 Y 以匹配 MATLAB 的显示方式

    % 保存为 .tif
    for z = 1:dims(3)
        if z == 1
            imwrite(volumeData(:, :, z), tifFilePath);
        else
            imwrite(volumeData(:, :, z), tifFilePath, 'WriteMode', 'append');
        end
    end
end
