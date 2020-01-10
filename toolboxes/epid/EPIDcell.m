function EPIDcell(varargin)
% EPIDcell.m is the highest level function in the EPID toolbox. This
% function detects and saves the location of the cell boundaries found
% withint the epidermal cell files found from EPIDlane.
% INPUTS:
%   varargin (varies) - Name, value pairs (see below)

defaultSPM = 'all';
defaultTimeSetting = 'all';
defaultForeground = 'bright';
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
addParameter(p, 'SPM', defaultSPM);  % The number of the specimen
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
            error('No EPID directory has been created. Try running EPIDlane first');
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
            tSave = [epidDir '/cells' num2str(t, '%.4u') '.mat']; % Path to save the data from this function
            tLoad = [epidDir '/lanes' num2str(t, '%.4u') '.mat']; % Path to load the data for this function
            
            if ~exist(tLoad, 'file') % Load the files created by EPIDlane.m
                error('No epidermal lanes detected: EPIDlane must be called for this time stamp before this function can run');
            else
                load(tLoad);
            end
            
            [cwidx, igradx2, igrady2, itipup] = epidcellpredict(spm, t, imz, angl, epidLanes); % Predict the cell wall locations in the epidermal lanes
            
            save(tSave, 'cwidx', 'igradx2', 'igrady2', 'itipup'); % Save the data
        end
    end
end
end

