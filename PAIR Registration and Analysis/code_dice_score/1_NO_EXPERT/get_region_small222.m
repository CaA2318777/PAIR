function region_anno = get_region_small222(Annotation, resolution)

    load('Y:\xxx\xxx\HD1\altas_dataset\labelmapper.mat')
    disp('small222')
    region_anno = uint8(Annotation*0);

    %% cc 1197 1205 txt
    start_num = find(cellfun(@(x) strcmp(x, 'cc'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'cst'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 1; 
    
    
    %% VL 
    start_num = find(cellfun(@(x) strcmp(x, 'VL'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'V3'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 2; 
    
    %% fx 
    start_num = find(cellfun(@(x) strcmp(x, 'fx'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'hc'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 3;  


    %% AD 
    start_num = find(cellfun(@(x) strcmp(x, 'AD'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'IAM'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 4;  

    %% LGd 
    start_num = find(cellfun(@(x) strcmp(x, 'LGd'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'DORpm'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 5;  

    %% AV
    start_num = find(cellfun(@(x) strcmp(x, 'AV'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'AV'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 6;  

        %% LGv
    start_num = find(cellfun(@(x) strcmp(x, 'LGv'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'LGv'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 7;  

        %% SNr
    start_num = find(cellfun(@(x) strcmp(x, 'SNr'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'SNr'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 8;     

        %% NLL
    start_num = find(cellfun(@(x) strcmp(x, 'NLL'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'NLL'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 9;      

            %% DCO
    start_num = find(cellfun(@(x) strcmp(x, 'DCO'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'DCO'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 10;  

            %% AQ
    start_num = find(cellfun(@(x) strcmp(x, 'AQ'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'AQ'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 11;

            %% VCO
    start_num = find(cellfun(@(x) strcmp(x, 'VCO'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'VCO'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 12;

            %% V4
    start_num = find(cellfun(@(x) strcmp(x, 'V4'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'V4'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 13;

            %% LH
    start_num = find(cellfun(@(x) strcmp(x, 'LH'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'LH'), labelmapper)) - 1;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 14;   

            %% LS
    start_num = find(cellfun(@(x) strcmp(x, 'LS'), labelmapper)) - 1;
    end_num = find(cellfun(@(x) strcmp(x, 'SF'), labelmapper)) - 2;
    temp = double(Annotation>=start_num & Annotation<=end_num);
    disp(sum(temp(:))*(resolution*1e-3)^3)
    region_anno(temp>0) = 15;   


end