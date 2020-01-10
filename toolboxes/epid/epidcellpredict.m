function [lanedata, igradx2, igrady2, itipup] = epidcellpredict(spm, t, imz, angl, epidLanes, varargin)
% epidcellpredict(spm, t, imz, angl, epidLanes, varargin) - predicts the points in
% epidLanes in which cell boundaries are detected.
% Inputs:
%   spm (int) - specimen identifier
%   t (int) - time stamp to evaluate
%   imz (NxM double) - image to evaluate (dark foreground assumed)
%   angl (int) - angle to rotate imz to get an upright root


ifilt = imgaussfilt(imz, 2);  % Filter the image
iphase = phasesym(ifilt, 4, 6); % Local symmetry operation

itip = tipmap(spm, t); % Holds the distance from the qc/tip

iup = imrotate(imz, angl); % Rotate the images
itipup = imrotate(itip, angl);
S = size(iup);

immask = showMask(spm, t, false); % Grab the mask of this specimen and this time stamp

[~, igradx2, ~, igrady2] = doubledxy(iup, 2); % Find the second derivate gradient of the image

lanedata = celllocalminlanes(igradx2, igrady2, iphase, immask, angl, epidLanes, itipup); % Find the cell walls in the epidermal lanes
end

