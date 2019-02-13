function [x, y] = findTip(avPath, I)
%findTip.m - This function finds the tip of an arabidopsis root from a
%1920x1920xZ brightfield image aquired from a lightsheet microscope. 
%Inputs:
%   av - this is the path to the 'av.mat' file which is a filter that has
%       been trained to be used with image recognition kernel operations to
%       indicate hotspots for the tip.
%   I - The 1920x1920xZ image from the Brightfield image in double format
%   (0-1).
%Outputs:
%   x, y - The x and y pixel locations that the algorithm detected.

load(avPath);

for z = 1:size(I, 3)
    I(:, :, z) = imgradient(imgaussfilt(I(:, :, z), 2));
end
Imax = max(I, [], 3); % Get the maximum projection of the image
Imax = imresize(Imax, [480, 480]); % Resize image to a 480x480
Imaxsmooth = Imax;
% Imaxsmooth = imgradient(imgaussfilt(Imax, 2)); % Smooth the image and get the gradient

Sfilt = size(av); % Size of the av filter
Sim = size(Imax); % Size of the Imax image (should be 1920x1920)

L = (Sfilt(1)-1)./2; % Half the size of the filter

Imaxpad = padarray(Imaxsmooth, [L, L], 0, 'both'); % Pad the image with zeros so that the indices don't run over the image
Ifilt = zeros(Sim);

for row = 1:Sim(1) % Go through each pixel in the original image and apply a least squares algorithm
    for col = 1:Sim(2)
        Ismall = Imaxpad(row:row+Sfilt(1)-1, col:col+Sfilt(2)-1); % Crop out image
        
        isAv = mean(Ismall(:)); % Normalize the cropped image
        isStd = std(Ismall(:));
        Ismall = (Ismall-isAv)./isStd;
        
        Ifilt(row, col) = sum(sum(abs(Ismall-av)));
    end
end

Ifilt = Ifilt(L:end-L, L:end-L); % Crop out the edges because they are used to filter the black padded portions of the image
newS = size(Ifilt);
[~, p] = min(Ifilt(:));
[row, col] = ind2sub(newS, p);

x = (col+L)*4; % Added L because it cropped the edges and multiply by 4 because the original image was rescaled to 480
y = (row+L)*4;

% imshow(Imax)
% hold on
% scatter(col+L, row+L)
end

