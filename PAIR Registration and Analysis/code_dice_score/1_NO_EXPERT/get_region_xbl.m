function region_anno = get_region_xbl(Annotation, resolution, num)
    load('Y:\xxx\xxx\HD1\altas_dataset\labelmapper.mat')
    region_anno = uint8(Annotation*0);

    %% STR
    start_num = find(cellfun(@(x) strcmp(x, 'STR'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'PAL'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    str_vol = sum(temp(:))*(resolution*1e-3)^3;
    region_anno(temp>0) = 1; 

    %% cc 
    start_num = find(cellfun(@(x) strcmp(x, 'cc'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'cst'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    cc_vol = sum(temp(:))*(resolution*1e-3)^3;
    region_anno(temp>0) = 2; 

    %% CTX 
    start_num = find(cellfun(@(x) strcmp(x, 'CTX'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'CNU'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    ctx_vol = sum(temp(:))*(resolution*1e-3)^3;
    region_anno(temp>0) = 3;  

    % 总体积
    total_vol = sum(Annotation(:)>0)*(resolution*1e-3)^3;

    % 写入Excel到该脑子的dice_score文件夹
    datapath = ['F:\lab\align\xxx\',num2str(num),'\dice_score\'];
    if ~exist(datapath, 'dir')
        mkdir(datapath);
    end
    excel_path = [datapath, num2str(num),'_brain_info.xlsx'];
    header = {'STR','cc','CTX','total_volume'};
    data = {str_vol, cc_vol, ctx_vol, total_vol};
    writecell([header; data], excel_path);
end