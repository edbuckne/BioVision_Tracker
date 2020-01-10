function [Imask] = predictrootmaskunet(Iin, varargin)
defaultMaskNetwork = 'UNET';

p = inputParser;
addRequired(p, 'Iin');
addParameter(p, 'MaskNetwork', defaultMaskNetwork);
parse(p, Iin, varargin{:});

S = size(Iin);
load(p.Results.MaskNetwork);  % Use the semantic segmentation network to create a mask of the root
I8bit = im2uint8(Iin);
Ipredict = net.predict(imresize(I8bit, [128, 128]));
Imask = imresize(imgaussfilt(Ipredict, 1), S(1:2)) > 0.5;
Imask = Imask(:, :, 1);
end

