function [ I, zNum ] = microImInputRaw( SPM, TM, CM, VIEW )
    
    SPMstr = num2str(SPM,'%.2d'); %Create strings for each parameter
    TMstr = num2str(TM,'%.4d');
    CMstr = num2str(CM,'%.1d');
    VIEWstr = num2str(VIEW);
    Zstr = num2str(1,'%.3u');
    
    if exist([pwd '/SPM' SPMstr '/TM' TMstr '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif'],'file')
        z=1; Zstr = num2str(z,'%.3u');
        while exist([pwd '/SPM' SPMstr '/TM' TMstr '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif'],'file')           
            fileName = ['/SPM' SPMstr '/TM' TMstr '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif']; %Path to raw images
            I(:,:,z) = im2double(imread([pwd fileName]));
            z=z+1;
            Zstr = num2str(z,'%.3u');
        end
        zNum=z-1;
    elseif exist([pwd '/SPM' SPMstr '/TM' TMstr '/TM' TMstr '_CM' CMstr '_v' VIEWstr '.tif'],'file')
        fileName = ['/SPM' SPMstr '/TM' TMstr '/TM' TMstr '_CM' CMstr '_v' VIEWstr '.tif']; %Path to raw images
        zNum = size(imfinfo([pwd fileName]),1); %Get the number of zStacks
        for z=1:zNum %Obtain each image
            I(:,:,z) = im2double(imread([pwd fileName],z));
        end
    elseif exist([pwd '/TM' TMstr '/TM' TMstr '_CM' CMstr '_v' VIEWstr '.tif'],'file')
        fileName = ['/TM' TMstr '/TM' TMstr '_CM' CMstr '_v' VIEWstr '.tif']; %Path to raw images
        zNum = size(imfinfo([pwd fileName]),1); %Get the number of zStacks
        for z=1:zNum %Obtain each image
            I(:,:,z) = im2double(imread([pwd fileName],z));
        end
    elseif exist([pwd '/TM' TMstr '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif'],'file')
        z=1; Zstr = num2str(z,'%.3u');
        while exist([pwd '/TM' TMstr '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif'],'file')           
            fileName = ['/TM' TMstr '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif']; %Path to raw images
            I(:,:,z) = im2double(imread([pwd fileName]));
            z=z+1;
            Zstr = num2str(z,'%.3u');
        end
        zNum=z-1;
    else
        error('Image does not exist or you are not in the home directory');
    end
    
end
