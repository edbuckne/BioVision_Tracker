function [lanedata, igradx2, igrady2, itipup] = epidcellpredict(spm, t, imz, angl, epidLanes, xPix, xPixScale, varargin)
% epidcellpredict(spm, t, imz, angl, epidLanes, xPix, xPixScale, varargin) - predicts the points in
% epidLanes in which cell boundaries are detected.
% Inputs:
%   spm (int) - specimen identifier
%   t (int) - time stamp to evaluate
%   imz (NxM double) - image to evaluate (dark foreground assumed)
%   angl (int) - angle to rotate imz to get an upright root

defaultRedoTipMap = false;

p = inputParser();
addParameter(p, 'RedoTipMap', defaultRedoTipMap); % Look for the tip map before trying to make another one to save time

parse(p, varargin{:});

Simz = size(imz);
ifilt = imgaussfilt(imz, 2);  % Filter the image
iphase = phasesym(ifilt, 4, 6); % Local symmetry operation

if p.Results.RedoTipMap || ~exist(['SPM' num2str(spm, '%.2u') '/EPID/cells' num2str(t, '%.4u') '.mat'], 'file')
    itip = rescaleimz(tipmap(spm, t), xPix, xPixScale); % Holds the distance from the qc/tip
    itipup = imrotate(itip, angl);
else
    load(['SPM' num2str(spm, '%.2u') '/EPID/cells' num2str(t, '%.4u') '.mat'], 'itipup');
end

iup = imrotate(imz, angl); % Rotate the images
S = size(iup);

immask = imresize(showMask(spm, t, false), Simz); % Grab the mask of this specimen and this time stamp

[~, igradx2, ~, igrady2] = doubledxy(iup, 2); % Find the second derivate gradient of the image

lanedata = celllocalminlanes(igradx2, igrady2, iphase, immask, angl, epidLanes, itipup); % Find the cell walls in the epidermal lanes
end

