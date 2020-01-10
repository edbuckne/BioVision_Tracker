function [immask] = maskrootpi(im, p, cellwall)
% maskrootpi.m - takes in a double greyscale image (im) and a percentage
% value (p) and calculates a mask for this image. It assumes it is an
% upright root. cellwall input should be a 1 if the cell walls are bright
% and a 0 if the cell walls are dark. The default is cell walls are bright (1).

if ~exist('cellwall', 'var')
    cellwall = 1;
end

if cellwall == 1
    im = 1-im;
end

Imask = pctth(im, p);

Imask2 = padarray(Imask, [1, 1], 'both');

Imask2(1, 1:end) = 1;  % Fill all holes
Imask2 = imfill(Imask2, 'holes');

Imask2(1, 1:end) = 0;
Imask2(1:end, end) = 1;
Imask2 = imfill(Imask2, 'holes');

Imask2(1:end, end) = 0;
Imask2(1:end, 1) = 1;
Imask2 = imfill(Imask2, 'holes');

Imask2(1:end, 1) = 0;
Imask2(end, 1:end) = 1;
Imask2 = imfill(Imask2, 'holes');

immask = Imask2(2:end-1, 2:end-1);
end

