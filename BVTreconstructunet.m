function BVTreconstructunet(SPM, varargin)
% BVTreconstrucunett.m
%
% Highest level function on the BVT software pipeline. This function is
% responsible for indicating and storing the midline information in
% addition to storing a mask image of the specimen from a flourescent
% channel showing stained cell walls.

defaultTimeSetting = 'all';  
defaultForeground = 'dark';
defaultTimeRange = 1;  
defaultMaskNetwork = 'UNET';

expectedTimeSetting = {'all', 'spec'};
expectedForeground = {'dark', 'bright'};

p = inputParser();
addRequired(p, 'SPM');  % The number of the specimen
addParameter(p, 'MaskNetwork', defaultMaskNetwork);  % The name of the .mat file that holds the semantic segmentation network
addParameter(p, 'TimeRange', defaultTimeRange);  % Only read if the 'TimeSetting' is set to 'spec'. Tells which time stamps to evaluate
addParameter(p, 'TimeSetting', defaultTimeSetting, ...  
    @(x) any(validatestring(x, expectedTimeSetting)));  % 'all' means all time stamps will be evaluated and 'spec' means a range has been specified
addParameter(p, 'Foreground', defaultForeground, ...  
    @(x) any(validatestring(x, expectedForeground)));  % 'dark' means the background of the image is dark while 'bright' means the opposite
parse(p, SPM, varargin{:});

load('data_config.mat');

sInd = find(tSpm(:, 1)==SPM);  % Find the index of this specimen in the tSpm matrix

if strcmp(p.Results.TimeSetting, 'all')  % Indicate whether the user specifies a time range
    tRange = tSpm(sInd, 2):tSpm(sInd, 3);
else
    tRange = p.Results.TimeRange;
end

cd(['SPM' num2str(SPM, '%.2u')]); % Go to specimen directory 

if ~exist('MIDLINE') % If the MIDLINE directory doesn't exist, create it
    mkdir MIDLINE
end

f = waitbar(0, 'Reconstructing surface');
for i = 1:length(tRange) % Run this operation for each time stamp
    t = tRange(i);
    prog = i./length(tRange);
    waitbar(prog, f, ['Reconstructing surface ' num2str(t) ' of ' num2str(tRange(end))]);
    
    I = microImInputRaw(SPM,t,2,1); % Load image from the data set
    if strcmp(p.Results.Foreground, 'dark')
        I = 1-I;
    end
    
    SS = size(I);
    Imask1 = zeros(SS);
    
    if length(SS) == 3  % Create a 3D or a 2D mask depending on the image dimensions
        mZ = round(size(I, 3)/2);
        if exist(['MIDLINE/mask' num2str(t, '%.4u') '_3D.tif'], 'file')  % Delete the 3D mask that is there
            delete(['MIDLINE/mask' num2str(t, '%.4u') '_3D.tif']);
        end
        for z = 1:SS(3)
            Imask1(:, :, z) = predictrootmaskunet(I(:, :, z), 'MaskNetwork', p.Results.MaskNetwork);
            loop = true;
            while loop
                try
                    imwrite(Imask1(:, :, z), ['MIDLINE/mask' num2str(t, '%.4u') '_3D.tif'], 'writemode', 'append');
                    loop = false;
                catch
                    loop = true;
                end
            end
        end
        Imask = max(Imask1, [], 3);
    else
        mZ = 1;
        Imask = predictrootmaskunet(I, 'MaskNetwork', p.Results.MaskNetwork);
    end
    
    S = calcMidline(Imask);
    save(['MIDLINE/ml' num2str(t, '%.4u') '.mat'], 'S', 'mZ');
    imwrite(Imask, ['MIDLINE/mask' num2str(t, '%.4u') '.tif']);
end
close(f);
cd ..
end

