function [Imask] = showMask(spm, t, show)
spmPath = ['SPM' num2str(spm, '%.2u')];
Imask = im2double(imread([spmPath '/MIDLINE/mask' num2str(t, '%.4u') '.tif']));

if show
    figure;
    imshow(Imask);
end
end

