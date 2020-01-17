function [allLanes, epidLanes, angl] = epidlanepredict(imz, spm, varargin)
% epidlanepredict(imz, spm, varargin) predicts the epidermal cell lanes in a fluorescence microscopy
% image of an arabidopsis root stained with PI cell wall marker.
% INPUTS:
%   imz (double) - image of root (dark cell walls)
%   spm (int) - specimen identifier
% OUTPUTS:
%   allLanes (cell) - All lanes found on the root
%   epidLanes (cell) - Lanes detected to be epidermal lanes

defaultMaskNetwork = 'UNET';  % The network used to predict the mask of the root
defaultEpidModel = 'epidMdl';  % The model used for predicting epidermal cells
defaultMaskMethod = 'net';
defaultLateralResolution = 1;  % The resolution of pixels in microns
defaultMaskIn = []; 
defaultPlotSetting = false;  % Whether or not to plot the image once processed
defaultImageSetting = 'BVT';

expectedMaskMethod = {'net', 'input'};
expectedImageSetting = {'BVT', 'directory', 'input'};

p = inputParser;
addRequired(p, 'imz');
addParameter(p, 'MaskNetwork', defaultMaskNetwork);
addParameter(p, 'LateralResolution', defaultLateralResolution);
addParameter(p, 'EpidModel', defaultEpidModel);
addParameter(p, 'MaskIn', defaultMaskIn);
addParameter(p, 'MaskMethod', defaultMaskMethod, ...
    @(x) any(validatestring(x, expectedMaskMethod)));
addParameter(p, 'PlotSetting', defaultPlotSetting, ...
    @(x) islogical(x));
addParameter(p, 'ImageSetting', defaultImageSetting, ...
    @(x) any(validatestring(x, expectedImageSetting)));  % 'BVT' means read image from the BVT directory format, 'directory' means all .tif images in the current directory, and 'input' means the user has inputed an image to analyze
parse(p, imz, varargin{:});

load('./data_config'); % Load configuration file

ifilt = imgaussfilt(imz, 2);  % Filter the image

iphase = phasesym(ifilt, 4, 6); % Local symmetry operation

itip = tipmap(spm, 1); % Holds the distance from the qc/tip

if strcmp(p.Results.MaskMethod, 'input')
    immask = p.Results.MaskIn; % Takes in mask given to us
else
    immask = predictrootmaskunet(imz, 'MaskNetwork', p.Results.MaskNetwork);  % Predicts a mask for the root
end

angl = findrootangl(immask); % Get the angle of the image

iup = imrotate(imz, angl); % Rotate the image
itipup = imrotate(itip, angl);
S = size(iup);

allLanes = findalllanes(iup, immask, iphase, angl); % Find all lanes associated with this image

allLanes = mergelanes(allLanes, xPix); % Merge lanes close together

X = collectlanefeatures(allLanes, itip, immask, angl, xPix); % Collect features for epidermal detection

load(p.Results.EpidModel); % Predict the epidermal lanes
Y = mdl.predict(X);

epidLanes = cell(0); % Gather epid-predicted lanes
for i = 1:length(Y)
    if Y(i)==1
        epidLanes{end+1} = allLanes{i};
    end
end

if length(epidLanes)>2 % There should only be 2 epidermal lanes
    elen = zeros(length(epidLanes), 1); % Collect how long each lane is
    for i = 1:length(epidLanes)
        elen(i) = size(epidLanes{i}, 1); % Store the length of this lane
    end
    [~, id] = sort(elen, 'Descend');
    epidLanes = {epidLanes{id(1)}, epidLanes{id(2)}};
end
end

