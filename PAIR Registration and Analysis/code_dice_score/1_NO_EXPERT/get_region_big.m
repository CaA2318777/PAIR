function [region_anno,area_volumn] = get_region_big(Annotation, resolution)

    load('Y:\xxx\xxx\HD1\altas_dataset\labelmapper.mat')
    disp('Sequence:  HPF, CTX, CB, CP, BS')
    region_anno = uint8(Annotation*0);
    area_volumn = zeros(6,1);

    %% CTX 3-570
    CTX1 = double(Annotation>=5 & Annotation<=453);
    CTX2 = double(Annotation>=493 & Annotation<=522);
    CTX3 = double(Annotation>=555 & Annotation<=569);
    CTX = CTX1+CTX2+CTX3;
    disp('CTX:')
    disp(sum(CTX(:))*(resolution*1e-3)^3)
    area_volumn(2) = (sum(CTX(:))*(resolution*1e-3)^3);
    region_anno(CTX>0) = 2;
    clear CTX
    
    %% HPF是Allen的HIP(也就是HPF减去Retrohippocampal region) 454-554
    HPF1 = double(Annotation>=456 & Annotation<=489);
    HPF2 = double(Annotation>=527 & Annotation<=554);
    HPF = HPF1 + HPF2;
    disp('HPF:')
    disp(sum(HPF(:))*(resolution*1e-3)^3)
    area_volumn(1) = (sum(HPF(:))*(resolution*1e-3)^3);
    region_anno(HPF>0) = 1;
    clear HPF1 HPF2 HPF
    
    
    %% CB [1020,1106] - 6
    CB = double(Annotation>=1014 & Annotation<=1100);
    CBC = double(Annotation==1172);
    ARB = double(Annotation==1188);
    CB = CB+CBC+ARB;
    disp('CB:')
    disp(sum(CB(:))*(resolution*1e-3)^3)
    area_volumn(3) = sum(CB(:))*(resolution*1e-3)^3;
    region_anno(CB>0) = 3;
    clear CB
    
    %% CP [579] - 6
    CP = double(Annotation==573);
    disp('CP:')
    disp(sum(CP(:))*(resolution*1e-3)^3)
    area_volumn(4) = (sum(CP(:))*(resolution*1e-3)^3);
    region_anno(CP>0) = 4;
    clear CP
    
    %% bs [645,1019] - 6
    BS = double(Annotation>=639 & Annotation<=1013);
    disp('BS:')
    disp(sum(BS(:))*(resolution*1e-3)^3)
    area_volumn(5) = (sum(BS(:))*(resolution*1e-3)^3);
    region_anno(BS>0) = 5;
    clear BS

    %%
    ALL = double(Annotation>0);
    area_volumn(6) = (sum(ALL(:))*(resolution*1e-3)^3);

end