function EPIDtz(varargin)
% EPIDtz.m is the highest level function in the EPID toolbox. This
% function analyzes the features of the epidermal cells detected by
% EPIDcell to make a decision on the location of the transition
% zone/elongation zone boundary
% INPUTS:
%   varargin (varies) - Name, value pairs (see below)

defaultSPM = 'all';
defaultTimeSetting = 'all';
defaultForeground = 'bright';
defaultThreeDSetting = '3D';
defaultTimeRange = 1;
defaultMaskNetwork = 'UNET';
defaultTZModel = 'tzMdl';
defaultImageSetting = 'BVT';
defaultRedoMask = false;

expectedTimeSetting = {'all', 'spec'};
expectedForeground = {'dark', 'bright'};
expectedThreeDSetting = {'3D', '2D'};
expectedImageSetting = {'BVT', 'directory', 'input'};

p = inputParser();
addParameter(p, 'SPM', defaultSPM);  % The number of the specimen
addParameter(p, 'MaskNetwork', defaultMaskNetwork);  % The name of the .mat file that holds the semantic segmentation network
addParameter(p, 'TimeRange', defaultTimeRange);  % Only read if the 'TimeSetting' is set to 'spec'. Tells which time stamps to evaluate
addParameter(p, 'RedoMask', defaultRedoMask); % This options tells the function to recalculate the mask or to use showMask
addParameter(p, 'TZModel', defaultTZModel); % The model used for predicting the cell at the TZ/EZ boundary
addParameter(p, 'TimeSetting', defaultTimeSetting, ...
    @(x) any(validatestring(x, expectedTimeSetting)));  % 'all' means all time stamps will be evaluated and 'spec' means a range has been specified
addParameter(p, 'Foreground', defaultForeground, ...
    @(x) any(validatestring(x, expectedForeground)));  % 'dark' means the background of the image is dark while 'bright' means the opposite
addParameter(p, 'ThreeDSetting', defaultThreeDSetting, ...
    @(x) any(validatestring(x, expectedThreeDSetting)));  % '3D' means the image has z-stacks and the user has to pick a stack, '2D' means the image has 1 stack and the user doesn't choose
addParameter(p, 'ImageSetting', defaultImageSetting, ...
    @(x) any(validatestring(x, expectedImageSetting)));  % 'BVT' means read image from the BVT directory format, 'directory' means all .tif images in the current directory, and 'input' means the user has inputed an image to analyze

parse(p, varargin{:});

load('data_config.mat');

if strcmp(p.Results.ImageSetting, 'BVT') % Evaluate images in the BVT directory format
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
            error('EPIDlane and EPIDcell must be run before EPIDtz');
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
            tSaveTZ = [epidDir '/tz' num2str(t, '%.4u')]; % Path to save tz data            
            
            [Xdata, score] = epidestimatetz(spm, t, 'TZModel', p.Results.TZModel);
            
            save(tSaveTZ, 'Xdata', 'score'); % Save the data
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

