function [Itip] = createtipmap(spm, t, S, yS)
% createtipmap.m takes in the specimen number (spm), time stamp (t), array
% holding the midline (S), and the largest y value to go to on the midline
% (yS) and creates a double-type image (Itip) that tells how far away each pixel
% is from the yS location of the midline along the length of the midline. 

load('data_config');
spmdir = ['SPM' num2str(spm, '%.2u')];
if ~exist('S', 'var')
    load([spmdir '/MIDLINE/ml' num2str(t, '%.4u')]);
end
if exist([spmdir '/tipTrack'], 'dir')
    load([spmdir '/tipTrack']);
end
if ~exist('yS', 'var')
    yS = tipLoc(2);
end
Imask = showMask(spm, t, false); % Get the mask of the image to filter non root tissue


imS = size(Imask);  % Create an x and y image for pixel locations
minim = ones(imS(1), imS(2)) .* imS(1);
Itip = zeros(imS(1), imS(2));
[imx, imy] = meshgrid(1:imS(2), 1:imS(1));

if yS > length(S)
    error('Your tip location is farther down than your midline');
end

count = 0;
for ydy = yS:-1:2
    x = S(ydy);
    y = ydy;
    
    count = count + sqrt((S(ydy)-S(ydy-1)).^2 + 1) .* xPix;
    
    distim = sqrt((imx-x) .^ 2 + (imy-y) .^2);
    minim = min(cat(3, distim, minim), [], 3);
    Itip(minim==distim) = count;
end
    
end

