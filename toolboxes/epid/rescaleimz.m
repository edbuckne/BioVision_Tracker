function [imz] = rescaleimz(imz, xPix, xPixGoal)
% rescaleimz(imz, xPix, xPixGoal) - Rescales the image of imz to change the
% xy pixel resolution from xPix to xPixGoal.

scalevalue = xPix./xPixGoal;
imz = imresize(imz, scalevalue);

end

