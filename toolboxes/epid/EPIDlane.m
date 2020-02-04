function EPIDlane(varargin)
% EPIDlane.m is the highest level function in the EPID toolbox. This
% function detects and saves the lanes of epidermal cells. Data are saved
% in SPMXX/EPID/lanesTTTT.mat. BVTreconstruct or BVTreconstructunet must be
% ran before this function is run if evaluating data in BVT format.
% INPUTS:
%   varargin (varies) - Name, value pairs (see below)
defaultSPM = 'all';
defaultTimeSetting = 'all';
defaultForeground = 'bright';
defaultThreeDSetting = '3D';
defaultTimeRange = 1;
defaultMaskNetwork = 'UNET';
defaultEpidModel = 'epidMdl';
defaultImageSetting = 'BVT';
defaultXPix = 0.69;
defaultInputImage = [];
defaultRedoMask = false;
defaultRedoZStack = false;

expectedTimeSetting = {'all', 'spec'};
expectedForeground = {'dark', 'bright'};
expectedThreeDSetting = {'3D', '2D'};
expectedImageSetting = {'BVT', 'directory', 'input'};

p = inputParser();
addParameter(p, 'SPM', defaultSPM);  % The number of the specimen
addParameter(p, 'MaskNetwork', defaultMaskNetwork);  % The name of the .mat file that holds the semantic segmentation network
addParameter(p, 'TimeRange', defaultTimeRange);  % Only read if the 'TimeSetting' is set to 'spec'. Tells which time stamps to evaluate
addParameter(p, 'InputImage', defaultInputImage);  % Only read if the 'ImageSetting' is set to 'input'
addParameter(p, 'RedoMask', defaultRedoMask); % This options tells the function to recalculate the mask or to use showMask
addParameter(p, 'EpidModel', defaultEpidModel); % The model used for predicting epidermal lanes
addParameter(p, 'RedoZStack', defaultRedoZStack); % If this function has already been ran, no need to re-pick the z-stack to evaluate if this is false
addParameter(p, 'XPix', defaultXPix); % Scale the image so that each pixel has this resolution
addParameter(p, 'TimeSetting', defaultTimeSetting, ...
    @(x) any(validatestring(x, expectedTimeSetting)));  % 'all' means all time stamps will be evaluated and 'spec' means a range has been specified
addParameter(p, 'Foreground', defaultForeground, ...
    @(x) any(validatestring(x, expectedForeground)));  % 'dark' means the background of the image is dark while 'bright' means the opposite
addParameter(p, 'ThreeDSetting', defaultThreeDSetting, ...
    @(x) any(validatestring(x, expectedThreeDSetting)));  % '3D' means the image has z-stacks and the user has to pick a stack, '2D' means the image has 1 stack and the user doesn't choose
addParameter(p, 'ImageSetting', defaultImageSetting, ...
    @(x) any(validatestring(x, expectedImageSetting)));  % 'BVT' means read image from the BVT directory format, 'directory' means all .tif images in the current directory, and 'input' means the user has inputed an image to analyze

parse(p, varargin{:});

load('./data_config.mat');
imzloaded = false;

if strcmp(p.Results.ImageSetting, 'BVT')||strcmp(p.Results.ImageSetting, 'input') % Evaluate images in the BVT directory format
    if ischar(p.Results.SPM) % Determine if all specimen, or just 1
        if strcmp(p.Results.SPM, 'all')
            spmlist = tSpm(:, 1)';
        else
            error(['I''m not sure what you mean by ' p.Results.SPM ', this should be ''all'' or a number']);
        end
    elseif isnumeric(p.Results.SPM)
        spmlist = round(p.Results.SPM);
    else
        error('Check your SPM variable. It should be ''all'' or a number');
    end
    
    for spm = spmlist % Go through all specimen
        spmDir = ['SPM' num2str(spm, '%.2u')];
        disp(spmDir); % Print which specimen is being evaluated
        
        epidDir = [spmDir '/EPID']; % Ensure EPID directory is created
        if ~exist(epidDir, 'dir')
            mkdir(epidDir);
        end
        
        if strcmp(p.Results.TimeSetting, 'all') % Determine the time ranges for this specimen
            tlist = tSpm(tSpm(:, 1) == spm, 1):tSpm(tSpm(:, 1) == spm, 2);
            if isempty(tlist)
                tlist = 1;
            end
        elseif strcmp(p.Results.TimeSetting, 'spec')
            tlist = p.Results.TimeRange;
        else
            error('Time range parameter error');
        end
        
        for t = tlist % Go through all time stamps of this specimen
            tSave = [epidDir '/lanes' num2str(t, '%.4u') '.mat']; % Path to save the data from this function
            
            if strcmp(p.Results.ImageSetting, 'BVT')
                if (~p.Results.RedoZStack)&&(exist(tSave, 'file'))
                    load(tSave, 'imz');
                    imzloaded = true;
%                     imz = rescaleimz(imz, xPix, p.Results.XPix); % Scale the image so that it has this resolution
                else
                    I3d = microImInputRaw(spm, t, 2, 1); % Grab the image
                    f = figure;
                    if length(size(I3d))==3 % 3D Image
                        imshow3D(I3d);
                        z = input('Which z stack should be used for lane detection? ');
                        close(f);
                        imz = I3d(:, :, z);
                    elseif length(size(I3d))==2 % 2D Image
                        imz = I3d;
                    else
                        error('Images must be 3D or 2D');
                    end
                    imz = rescaleimz(imz, xPix, p.Results.XPix); % Scale the image so that it has this resolution
                end
            elseif strcmp(p.Results.ImageSetting, 'input')
                imz = p.Results.InputImage;
            end
            
            if strcmp(p.Results.Foreground, 'bright')&&~imzloaded % Get the negative of this image if bright foreground
                imz = 1-imz;
            end
            
            if p.Results.RedoMask
                [allLanes, epidLanes, angl] = epidlanepredict(imz, spm, ...
                    'MaskNetwork', p.Results.MaskNetwork, ...
                    'EpidModel', p.Results.EpidModel, ...
                    'LateralResolution', p.Results.XPix);
            else
                [allLanes, epidLanes, angl] = epidlanepredict(imz, spm, ...
                    'MaskNetwork', p.Results.MaskNetwork, ...
                    'EpidModel', p.Results.EpidModel, ...
                    'MaskMethod', 'input', ...
                    'LateralResolution', p.Results.XPix, ...
                    'MaskIn', round(rescaleimz(showMask(spm, t, false), xPix, p.Results.XPix)));
            end
            save(tSave, 'imz', 'angl', 'allLanes', 'epidLanes'); % Save the data
        end
    end
elseif strcmp(p.Results.ImageSetting, 'directory') % Evaluate images in the current directory
    d = dir('*.tif'); % Look for .tif images
    N = length(d);
    
    data = cell(N, 5); % Will hold all of the lane data collected by this function
    
    for i = 1:N % Analyze each one
        imName = d(i).name; % Store the name of this image
        data{i, 1} = imName;
        
        iminf = imfinfo(imName); % Get the image metadata
        W = iminf.Width; H = iminf.Height; Z = length(iminf);
        if Z == 1 % 2D image
            imz = rgb2gray(im2double(imread(imName)));
        else
            Iin = zeros(H, W, Z); % Load and display the 3D image
            for z = 1:Z
                Iin(:, :, z) = rgb2gray(im2double(imread(imName)));
            end
            f = figure;
            imshow3D(Iin);
            
            z = input('Which z stack should be used for lane detection? '); % Chose the z stack to use
            close(f);
            imz = I3d(:, :, z);
        end
        
        f = figure; % Grab information about the QC
        imshow(imz);
        disp('Click where the QC is located and press enter');
        [xi,yi] = getpts(f);
        
        if i==1
            sld = uislider(f);
        end
    end
end
end

