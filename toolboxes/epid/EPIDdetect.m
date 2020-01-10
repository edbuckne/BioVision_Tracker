function EPIDdetect(SPM, varargin)
% EPIDdetect.m is a function at the highest level of the epid toolbox. This
% function takes in the specimen and detects the epidermal cells in that
% image.  The resulting images and data is stored in the EPID directory
% under each specimen directory.

defaultTimeSetting = 'all';  
defaultForeground = 'dark';
defaultThreeDSetting = '3D';
defaultTimeRange = 1;  
defaultMaskNetwork = 'UNET';
defaultImageSetting = 'BVT';
defaultInputImage = [];
defaultRedoMask = false;

expectedTimeSetting = {'all', 'spec'};
expectedForeground = {'dark', 'bright'};
expectedThreeDSetting = {'3D', '2D'};
expectedImageSetting = {'BVT', 'directory', 'input'};

p = inputParser();
addRequired(p, 'SPM');  % The number of the specimen
addParameter(p, 'MaskNetwork', defaultMaskNetwork);  % The name of the .mat file that holds the semantic segmentation network
addParameter(p, 'TimeRange', defaultTimeRange);  % Only read if the 'TimeSetting' is set to 'spec'. Tells which time stamps to evaluate
addParameter(p, 'InputImage', defaultInputImage);  % Only read if the 'ImageSetting' is set to 'input'
addParameter(p, 'RedoMask', defaultRedoMask); % This options tells the function to recalculate the mask or to use showMask
addParameter(p, 'TimeSetting', defaultTimeSetting, ...  
    @(x) any(validatestring(x, expectedTimeSetting)));  % 'all' means all time stamps will be evaluated and 'spec' means a range has been specified
addParameter(p, 'Foreground', defaultForeground, ...  
    @(x) any(validatestring(x, expectedForeground)));  % 'dark' means the background of the image is dark while 'bright' means the opposite
addParameter(p, 'ThreeDSetting', defaultThreeDSetting, ...  
    @(x) any(validatestring(x, expectedThreeDSetting)));  % '3D' means the image has z-stacks and the user has to pick a stack, '2D' means the image has 1 stack and the user doesn't choose
addParameter(p, 'ImageSetting', defaultImageSetting, ...  
    @(x) any(validatestring(x, expectedImageSetting)));  % 'BVT' means read image from the BVT directory format, 'directory' means all .tif images in the current directory, and 'input' means the user has inputed an image to analyze

parse(p, SPM, varargin{:});

load('data_config.mat');

sInd = find(tSpm(:, 1)==SPM);  % Find the index of this specimen in the tSpm matrix

if strcmp(p.Results.TimeSetting, 'all')  % Indicate whether the user specifies a time range
    tRange = tSpm(sInd, 2):tSpm(sInd, 3);
else
    tRange = p.Results.TimeRange;
end

if strcmp(p.Results.ImageSetting, 'input')  % If the user is inputing the image, the time range is just 1 point
    tRange = 1;
end

spmdir = ['SPM' num2str(SPM, '%.2u')]; % Specimen directory 

if ~exist([spmdir '/EPID']) % If the EPID directory doesn't exist, create it
    mkdir([spmdir '/EPID'])
end

for i = 1:length(tRange)
    t = tRange(i);
    
    if strcmp(p.Results.ImageSetting, 'input')  % Use the image according to the image setting
        I = p.Results.InputImage;
    else
        Iin = microImInputRaw(SPM, t, 2, 1);
        if strcmp(p.Results.ThreeDSetting, '3D')
            figure
            imshow3D(Iin);
            zchose = input('Which z stack should be used? ');
            close all
            I = Iin(:, :, zchose);
        else
            I = Iin(:, :, 1);
        end
    end
    
    if p.Results.RedoMask % This choses to send a parameter that tells epidpredict to use an existing mask or create a new one
        [Iout, P, Pepid, finalimage, X, epidlanes, angl] = epidpredict(I, SPM, t, 'Foreground', p.Results.Foreground, ...
        'MaskNetwork', p.Results.MaskNetwork, 'LateralResolution', xPix, 'MaskMethod', 'net');
    else
        [Iout, P, Pepid, finalimage, X, epidlanes, angl] = epidpredict(I, SPM, t, 'Foreground', p.Results.Foreground, ...
        'MaskNetwork', p.Results.MaskNetwork, 'LateralResolution', xPix, 'MaskMethod', 'input');
    end
    
    
    
    imz = I;
    save([spmdir '/EPID/ep' num2str(t, '%.4u')], 'Iout', 'imz', 'P', 'Pepid', 'X', 'epidlanes', 'angl');
    imwrite(finalimage, [spmdir '/EPID/ep' num2str(t, '%.4u') '.tif']);
end
end

