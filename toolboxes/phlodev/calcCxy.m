function [Cxy, Mu] = calcCxy(IroiMax)
sumI = sum(IroiMax(:));
IroiMaxNorm = IroiMax./sumI;
Nrows = size(IroiMaxNorm, 1);
Ncols = size(IroiMaxNorm, 2);
[X, Y] = meshgrid(1:Ncols, 1:Nrows);
MuX = sum(sum(IroiMaxNorm.*X));
MuY = sum(sum(IroiMaxNorm.*Y));
Mu = [MuX, MuY];
Cxy = sum(sum(IroiMaxNorm.*(X-MuX).*(Y-MuY)));
end

