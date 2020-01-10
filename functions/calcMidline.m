function [S] = calcMidline(Imask)
% calcMidline.m takes in a mask image of a root and calculates the midline
% that roots through it.

imsize = size(Imask);
S = zeros(imsize(1), 1);
filtorder = 25;

filtb = ones(filtorder, 1)./filtorder;

xvar = 1:imsize(2);

for row = 1:imsize(1)
    rowdata = Imask(row, :);  % Calculate the pixels in that row
    rowsum = sum(rowdata);
    rowdatanorm = rowdata./rowsum;
    
    S(row) = sum(rowdatanorm .* xvar);
end
S = S(S>0);
S = filtfilt(filtb, 1, S);
end

