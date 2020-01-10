function BVTconfig( dirName, ask, xPix, zPix )
% BVTconfig.m
%
%Highest level function in BVT framework.  This function takes in
%information from the user or a configuration file to be used for the
%data analysis.

dd = dir('SPM*');
spmN = size(dd, 1);
tSpm = zeros(spmN, 3);
for tt = 1:spmN
    spm = str2double(dd(tt).name(4:5));
    tSpm(tt, 1) = spm;
    
    cd(['SPM' num2str(spm, '%.2u')]); % Go to image data directory
    i = 1;
    while exist(['TM' num2str(i, '%.4u')]) % Find all of the time points
        i = i+1;
    end
    tSpm(tt, 2:3) = [1, i-1];
    cd ..
end

% spm = input('Which specimen do you want to view? ');
% cd(['SPM' num2str(spm, '%.2u')]); % Go to image data directory
% tmStart = 1; i = 1;
% while exist(['TM' num2str(i, '%.4u')])
%     i = i+1;
% end
% tmEnd = i-1;
% cd ..

% sprd = input('Is the GFP data at low contrast? (1 - yes, 0 - no) ');
if ~exist('dirName', 'var')
    dirName = input('Input the name of classifier: ', 's');
end
if ~exist([dirName '/' dirName '.mat'])
    try 
        load([dirName '/classifier.mat'])
    catch
        error('Classifier file does not exist')
    end
else
    load([dirName '/' dirName '.mat']);
end
if ~exist('ask', 'var')
    askin = input('Do you want to print a maximum projection time-course? (1-yes, 0 - no) ');
    if askin == 1
        ask = true;
    else 
        ask = false;
    end
end
if(ask)
    spm = input('Which specimen do you want to print? ');
    ss = find(tSpm(:, 1)==spm);
    cmm = input('Which camera do you want to print? ');
    disp(['Printing a maximum projection image of the data stack from specimen ' num2str(spm)]);
    tmStart = tSpm(ss, 2); tmEnd = tSpm(ss, 3);
    for t=tmStart:tmEnd
        disp(['Writing max projection for time ' num2str(t) ' of ' num2str(tmEnd)])
        [I,~] = microImInputRaw(spm,t,cmm,1);
        if t==tmStart
            [I,minp,maxp] = spreadPixelRange(I);
        else
            I = (I-minp)./maxp;
        end
        imwrite(max(I,[],3),['maxproj_' num2str(spm, '%.2u') '_cm' num2str(cmm) '.tif'],'writemode','append');
    end
end
clear ask

% for t=tmStart:tmEnd
%     TH(t) = THtmp;
% end
if ~exist('xPix', 'var')
    xPix = input('What is the pixel distance in microns for the x and y directions? ');
end
yPix = xPix;
if ~exist('zPix', 'var')
    zPix = input('What is the pixel distance in microns for the z direction? ');
end
xyratz = zPix/xPix;

clear I;
clear zTest;
clear z;
clear t;
clear i;

save('data_config.mat', 'tSpm', 'xPix', 'yPix', 'zPix', 'xyratz', 'classObj');
end

