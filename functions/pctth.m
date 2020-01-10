function [imth2] = pctth(I, pct)
% This function takes in a 2D image and a percentage value, it then
% thresholds the image at that percentage value of pixel intensities that
% it found
imint = I(:);
th = prctile(imint, pct);
imth = I<th;
imth2 = imfill(imth, 'holes');
end

