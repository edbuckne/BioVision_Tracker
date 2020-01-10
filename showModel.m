function [f, P] = showModel(spm, t, f)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
load('./data_config');
interpN = 16;
prune = 10;

spmdir = ['SPM' num2str(spm, '%.2u')]; % Include a model of the root if it is available
maskimage = [spmdir '/MIDLINE/mask' num2str(t, '%.4u') '.tif'];
maskdata = [spmdir '/MIDLINE/ml' num2str(t, '%.4u') '.mat'];

if exist(maskimage, 'file')&&exist(maskdata, 'file') % If the mask has been created, create a model
    load(maskdata); % Load the data and image
    Imask = im2double(imread(maskimage));
end

S = round(S); % Make sure S is round numbers

left = zeros(length(S), 1); % Holds the leftmost and rightmost points
right = zeros(length(S), 1);

lr = 1:size(Imask, 2); % Numbers the columns

for i = 1:length(S)
    lrpoints = lr.*Imask(i, :); % Get the points inside the mask
    lrpoints = lrpoints(lrpoints>0);
    
    left(i) = min(lrpoints); % Get the left and right points
    right(i) = max(lrpoints);
end

filtOrder = round(size(Imask, 1)./10); % Run data through a lowpass filter
b = ones(filtOrder, 1)./filtOrder;
left = round(filtfilt(b, 1, left));
right = round(filtfilt(b, 1, right));

leftmu = left.*xPix; % Tranform coordinates to coordinates in microns
rightmu = right.*xPix;
mZmu = mZ.*zPix;

surfpoints = zeros(length(S), 3, interpN); % Holds the interpolated surface points
for i = 1:length(S)
    rp = [rightmu(i)-S(i).*xPix, mZmu]; % Normalize the left and right point
    rad = rp(1); % This counts as the radius
    
    theta = linspace(0, 360, interpN+1);
    theta = theta(1:end-1);
    for j = 1:interpN
        surfpoints(i, :, j) = [rad.*cosd(theta(j))+S(i).*xPix, i, rad.*sind(theta(j))+mZmu];
    end
end

xSurf = round(surfpoints(:, 1, :)./xPix); % Inverse the transform made before
ySurf = surfpoints(:, 2, :);
zSurf = round(surfpoints(:, 3, :)./zPix);

P = [xSurf(:), ySurf(:), zSurf(:)];

if ~exist('f', 'var')
    f = figure();
end
hold on
scatter3(P(:, 1), P(:, 2), P(:, 3), '.b');
end

