function [Iout, P, Pepid, finalimage, X, epidlanes, angl] = epidpredict(I, spm, t, varargin)
% epidpredict.m takes in a double image of stained arabidopsis roots and
% autonomously detects which cells are epidermal cells.
% Name, Value:
%   'MaskNetwork' - 

defaultMaskNetwork = 'UNET';  % The network used to predict the mask of the root
defaultEpidModel = 'epidermis_svm';  % The model used for initially predicting epidermal cells
defaultForeground = 'dark';  % Whether it is brightfield or darkfield
defaultMaskMethod = 'net';
defaultLateralResolution = 1;  % The resolution of pixels in microns
defaultPlotSetting = false;  % Whether or not to plot the image once processed

expectedForeground = {'dark', 'bright'};
expectedMaskMethod = {'net', 'input'};

p = inputParser;
addRequired(p, 'I');
addParameter(p, 'MaskNetwork', defaultMaskNetwork);
addParameter(p, 'LateralResolution', defaultLateralResolution);
addParameter(p, 'EpidModel', defaultEpidModel);
addParameter(p, 'MaskMethod', defaultMaskMethod, ...
    @(x) any(validatestring(x, expectedMaskMethod)));
addParameter(p, 'Foreground', defaultForeground, ...
    @(x) any(validatestring(x, expectedForeground)));
addParameter(p, 'PlotSetting', defaultPlotSetting, ...
    @(x) islogical(x));
parse(p, I, varargin{:});

I = im2double(I);  % Make sure the image is a double 0-1
imsize = size(I);
ratioofsizex = imsize(2)./512;
ratioofsizey = imsize(1)./512;
I = imresize(I, [512, 512]);

load(p.Results.EpidModel);
if strcmp(p.Results.Foreground, 'dark')  % Make it a brightfield image
    I = 1 - I;
end
if isstring(p.Results.LateralResolution)  % Obtain the lateral resolution from the user or the data_config file
    if strcmp(p.Results.LateralResolution, 'data_config')
        load('data_config', 'xPix');
        latres = xPix;
    end
else
    latres = p.Results.LateralResolution;
end
latres = (imsize(1)./512).*latres;  % Rescale the lateral resolution when we resize the image

disp('Segmenting Cells');
if strcmp(p.Results.MaskMethod, 'net') % Recalculate the mask
    [Iout, P, Iath, Imask] = epidsegment(I, 'Foreground', 'Bright', ...
        'MaskNetwork', p.Results.MaskNetwork);  % Segment all cells
else
    try
        Imasktmp = showMask(spm, t, false);
        [Iout, P, Iath, Imask] = epidsegment(I, 'Foreground', 'Bright', ...
            'MaskNetwork', p.Results.MaskNetwork, 'MaskMethod', 'input', ...
            'Mask', Imasktmp);  % Segment all cells
    catch
        [Iout, P, Iath, Imask] = epidsegment(I, 'Foreground', 'Bright', ...
        'MaskNetwork', p.Results.MaskNetwork);  % Segment all cells
    end
end

% disp('Collecting Features of Cells');
% X = epidcollectfeatures(Iout, I, P, latres, ...
%     'MaskNetwork', p.Results.MaskNetwork);  % Use the epid model to make initial prediction of epidermal cells
% Y = epidsvmclassify(mdl, X, normlog, munorm, sdnorm);
% maskcum = epidplotclassifiedcells(Iout, I, P, Y, false);

disp('Detecting Cell Files');
[lanes, angl] = epidlanedetect(I, Iath, 'Foreground', 'Bright');  % Detect the cell lanes in the image

disp('Finalizing Epidermal Detection');
% [Pepid, epidlanes] = uselanesandepidmodel(lanes, imrotate(maskcum, angl), imrotate(Iout, angl), P);
[Pepid, epidlanes] = uselanesandepidmodel2(lanes, Iout, Imask, angl, P);

[X] = epidmeasurecelllength(epidlanes, Iout, angl, P, Pepid);

[~, finalimage] = epidplotclassifiedcells(Iout, I, P, Pepid, p.Results.PlotSetting);

% [Iout, P, Pepid, finalimage, X, epidlanes, angl]
Iout = imresize(Iout, imsize);
P(:, 1) = round(P(:, 1) .* ratioofsizex);
P(:, 2) = round(P(:, 2) .* ratioofsizey);
X = X .* ratioofsizey;
try
    epidlanes{1}(:, 1) = round(epidlanes{1}(:, 1) .* ratioofsizex);
    epidlanes{1}(:, 2) = round(epidlanes{1}(:, 2) .* ratioofsizex);
catch
    return;
end

try
    epidlanes{2}(:, 1) = round(epidlanes{2}(:, 1) .* ratioofsizey);
    epidlanes{2}(:, 2) = round(epidlanes{2}(:, 2) .* ratioofsizey);
catch
    return;
end
end

