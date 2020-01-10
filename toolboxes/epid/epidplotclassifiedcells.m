function [maskcum, maskrgb] = epidplotclassifiedcells(Iout, imz, P, Y, plotoption)
% Plots the results of epidsvmclassify.m

imrgb = zeros(size(imz, 1), size(imz, 2), 3);
randcolor = rand(length(Y), 3);
maskcum = zeros(size(imz));

for i = 1:length(Y)
    if Y(i)==1
        roimask = double(Iout==P(i, 3));
        maskcum = maskcum + roimask;
        imrgb = imrgb + cat(3, roimask.*randcolor(i, 1), roimask.*randcolor(i, 2), roimask.*randcolor(i, 3));
    end
end

imbw = cat(3, imz, imz, imz);
maskrgb = imbw.*0.5 + imrgb.*0.5;
if plotoption   
    f = figure();    
    imshow(maskrgb)
end
end

