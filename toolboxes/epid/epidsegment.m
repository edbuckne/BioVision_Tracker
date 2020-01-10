function [Iout, P, Iath, Imask] = epidsegment(Iin, varargin)
% epidsegment.m takes in an image (Iin) and partitions the image into
% different instances of cells and background.

defaultRes = 1;
defaultSmooth = 1;
defaultMask = 1;
defaultMaskMethod = 'net';
defaultMaskNetwork = 'UNET';
defaultForeground = 'dark';
expectedForeground = {'dark', 'bright'};
expectedMaskMethod = {'net', 'input'};
ydata = [50, 450];
wdata = [51, 11];
thdata = [0.45, 0.7];

p = inputParser;
addRequired(p, 'Iin');
addParameter(p, 'Resolution', defaultRes);
addParameter(p, 'Mask', defaultMask);
addParameter(p, 'MaskMethod', defaultMaskMethod, ...
    @(x) any(validatestring(x, expectedMaskMethod)));
addParameter(p, 'MaskNetwork', defaultMaskNetwork);
addParameter(p, 'Foreground', defaultForeground, ...
    @(x) any(validatestring(x, expectedForeground)));
addParameter(p, 'YRange', ydata);
addParameter(p, 'WindowRange', wdata);
addParameter(p, 'ThresholdRange', thdata);
addParameter(p, 'SmoothParameter', defaultSmooth);
parse(p, Iin, varargin{:});

S = size(Iin);

Iin = im2double(Iin);  % Transorm the image to range from 0-1, easier to work with
if strcmp(p.Results.Foreground, 'dark')
    Iin = 1 - Iin;
end

Ifilt1 = imgaussfilt(Iin, p.Results.SmoothParameter);  % Perform a filter and gradient operation
Igrad = imgradient(Ifilt1);

Iath = actadaptthresh(Ifilt1, p.Results.YRange, p.Results.ThresholdRange, ...
    p.Results.WindowRange);  % Perform the active adaptive threshold
D = bwdist(Iath);

if strcmp(p.Results.MaskMethod, 'net')
    load(p.Results.MaskNetwork);  % Use the semantic segmentation network to create a mask of the root
    I8bit = im2uint8(Iin);
    Ipredict = net.predict(imresize(I8bit, [128, 128]));
    Imask = imresize(imgaussfilt(Ipredict, 1), S(1:2)) > 0.5;
    Imask = Imask(:, :, 1);
elseif strcmp(p.Results.MaskMethod, 'input')
    Imask = p.Results.Mask;
end

Iws = im2double(watershed(D));  % Perform watershed on the image and multiply it by the mask
Iwsmask = Iws.*Imask;
Iout = Iwsmask;

Imax = imregionalmax(imgaussfilt(Iath, 2));  % Get the regional max points to indicate where cells are

[P, ~] = segMembrane(Iwsmask, Imax);  % Isolate on point per segmented region
end

