function trimZStacks( spmIn, spmOut, v, cams, mode )
% trimZStacks.m discards all z-stacks in the data that do not contain
% fluorescent signal (eg. the outside stacks). The inputs are the spmIn
% (the specimen number to be trimmed) and spmOut (the new specimen number).
% You can also choose to lower the sampling rate of the z-stacks based on
% the mode argument. v specifies the view to be trimmed, and cams specifies
% the cameras to be trimmed (in vector form).
%
% Author: Eli Buckner, NC State University

load('data_config.mat');
if ~(find(tSpm(:, 1)==spmIn))
    error('The spmIn you specified does not exist');
else
    tmStart = tSpm(tSpm(:, 1)==spmIn, 2); % Take out start and stop times
    tmEnd = tSpm(tSpm(:, 1)==spmIn, 3);
end
mkdir(['SPM' num2str(spmOut, '%.2u')]); % Make new directory
cd(['SPM' num2str(spmOut, '%.2u')]); 
newPath = pwd;
for t = tmStart:tmEnd
    mkdir(['TM' num2str(t, '%.4u')]); % Make directory for time stamps
end
cd ..

camSig = input('Which camera contains the signal? ');

cd(['SPM' num2str(spmIn, '%.2u')]); % Go to specimen directory
for t = tmStart:tmEnd
    disp(['Reformating image data ' num2str(t) ' of ' num2str(tmEnd)]);
    cd(['TM' num2str(t, '%.4u')]); % Go to time directory
    d = dir('*.tif');
    
    switch(mode)
        case 'sigTrim' % Trims out all z-stacks that do not contain signal in the channel specified
            Iinfo = imfinfo(['TM' num2str(t, '%.4u') '_CM' num2str(camSig) '_v' num2str(v) '.tif']); % Get info about the image
            zRange = [0, 0];
            for z = 1:length(Iinfo)
                disp(['Reading Z: ' num2str(z) ' of ' num2str(length(Iinfo)), ', T:' num2str(t)]);
                I = im2double(imread(['TM' num2str(t, '%.4u') '_CM' num2str(camSig) '_v' num2str(v) '.tif'], z));
                Iclass = classifyImage(classObj, imgaussfilt(I, classObj.Sigma));
                Isum = sum(Iclass(:)); % Classify the image and see if there is signal
                if (Isum>100)&&(zRange(1)==0) % Case: found signal and it is the first z-stack
                    zRange(1) = z;
                    zRange(2) = z;
                elseif (Isum>100)&&(zRange(1)>0) % Case: found signal and it is not the first z-stack
                    zRange(2) = z;
                end
            end
            if(zRange(1)==0)
                midZ = round(length(Iinfo)/2);
                zRange = [midZ midZ];
            end
            for CM = cams % Only trim the cameras specified in the input
                for z = zRange(1):zRange(2)
                    disp(['Writing CM:' num2str(CM) ', Z:' num2str(z) ', Z Range: ' num2str(zRange(1)) ' to ' num2str(zRange(2)) ', T:' num2str(t)]);
                    I = imread(['TM' num2str(t, '%.4u') '_CM' num2str(CM) '_v' num2str(v) '.tif'], z);
                    imwrite(I, ['../../SPM' num2str(spmOut, '%.2u') '/TM' num2str(t, '%.4u') '/TM' num2str(t, '%.4u') '_CM' num2str(CM) '_v' num2str(v) '.tif'], ...
                            'writemode', 'append');
                end
            end
        case 'cut2'
            Iinfo = imfinfo(['TM' num2str(t, '%.4u') '_CM' num2str(camSig) '_v' num2str(v) '.tif']); % Get info about the image
            for CM = cams % Only trim the cameras specified in the input
                for z = 1:2:length(Iinfo)
                    disp(['Writing CM:' num2str(CM) ', Z:' num2str(z) ', Z Range: ' num2str(1) ' to ' num2str(length(Iinfo)) ', T:' num2str(t)]);
                    I = imread(['TM' num2str(t, '%.4u') '_CM' num2str(CM) '_v' num2str(v) '.tif'], z);
                    imwrite(I, ['../../SPM' num2str(spmOut, '%.2u') '/TM' num2str(t, '%.4u') '/TM' num2str(t, '%.4u') '_CM' num2str(CM) '_v' num2str(v) '.tif'], ...
                            'writemode', 'append');
                end
            end
    end
    
    cd ..
end
cd ..

end

