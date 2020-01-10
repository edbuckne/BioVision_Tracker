function [Vx, Vy, MuX, MuY] = calcVxVy(IroiMax)
sumI = sum(IroiMax(:));
IroiMaxNorm = IroiMax./sumI;
Nrows = size(IroiMaxNorm, 1);
Ncols = size(IroiMaxNorm, 2);
[X, Y] = meshgrid(1:Ncols, 1:Nrows);
MuX = sum(sum(IroiMaxNorm.*X));
MuY = sum(sum(IroiMaxNorm.*Y));
Vx = sum(sum(IroiMaxNorm.*(X-MuX).^2));
Vy = sum(sum(IroiMaxNorm.*(Y-MuY).^2));
end

