function region_anno = get_region_small(Annotation, resolution)

    load('Y:\xxx\xxx\HD1\altas_dataset\labelmapper.mat')
    disp('Sequence:  aco, act, fr,  ipn, mtt')
    region_anno = uint8(Annotation*0);

      %% aco
    aco = double(Annotation==1111);
    disp('aco:')
    disp(sum(aco(:))*(resolution*1e-3)^3)
    region_anno(aco>0) = 1;
    clear aco
    
    %% act
    act = double(Annotation==1242);
    disp('act:')
    disp(sum(act(:))*(resolution*1e-3)^3)
    region_anno(act>0) = 2;
    clear act
    
    
    %% ipn [876,884] - 6
    ipn = double(Annotation>=870 & Annotation<=878);
    disp('ipn:')
    disp(sum(ipn(:))*(resolution*1e-3)^3)
    region_anno(ipn>0) = 4;
    clear ipn
    
    %% mtt 
    mtt = double(Annotation==1279);
    disp('mtt:')
    disp(sum(mtt(:))*(resolution*1e-3)^3)
    region_anno(mtt>0) = 5;
    clear mtt
    
    %% fr 
    fr = double(Annotation==1286);
    disp('fr:')
    disp(sum(fr(:))*(resolution*1e-3)^3)
    region_anno(fr>0) = 3;
    clear fr


end