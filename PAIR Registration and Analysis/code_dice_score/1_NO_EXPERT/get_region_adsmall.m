function [region_anno,area_volumn]  = get_region_adsmall(Annotation, resolution)

    load('Y:\xxx\xxx\HD1\altas_dataset\labelmapper.mat')
    disp('adsmall')
    region_anno = uint8(Annotation*0);

    %% CA1
    start_num = find(cellfun(@(x) strcmp(x, 'CA1'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'CA1'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(1) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 1;  
    

    %% CA2
    start_num = find(cellfun(@(x) strcmp(x, 'CA2'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'CA2'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(2) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 2; 


    %% CA3
    start_num = find(cellfun(@(x) strcmp(x, 'CA3'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'CA3'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(3) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 3;    

    %% DG
    start_num = find(cellfun(@(x) strcmp(x, 'DG'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'DG-sg'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(4) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 4;   

    %% EC
    start_num = find(cellfun(@(x) strcmp(x, 'ENT'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'ENTm6'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(5) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 5;   


    %% mPFC
    start_num = find(cellfun(@(x) strcmp(x, 'ACA'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'ACAv6b'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(6) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 6; 

    start_num = find(cellfun(@(x) strcmp(x, 'PL'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'PL6b'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(6) = area_volumn(6)+(sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 6; 


    start_num = find(cellfun(@(x) strcmp(x, 'ILA'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'ILA6b'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(6) = area_volumn(6)+(sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 6; 


    %% MO
    start_num = find(cellfun(@(x) strcmp(x, 'MO'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'MOs6b'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(7) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 7;   


    %% SS
    start_num = find(cellfun(@(x) strcmp(x, 'SS'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'GU'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(8) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 8; 

    %% Amyg
    start_num = find(cellfun(@(x) strcmp(x, 'LA'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'LA'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(9) = (sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 9; 

    start_num = find(cellfun(@(x) strcmp(x, 'BLA'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'BLAv'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(9) = area_volumn(9)+(sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 9; 


    start_num = find(cellfun(@(x) strcmp(x, 'BMA'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'BMAp'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(9) = area_volumn(9)+(sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 9; 

    start_num = find(cellfun(@(x) strcmp(x, 'PA'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'PA'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    area_volumn(9) = area_volumn(9)+(sum(temp(:))*(resolution*1e-3)^3);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 9; 

    %%
    ALL = double(Annotation>0);
    area_volumn(10) = (sum(ALL(:))*(resolution*1e-3)^3);


end