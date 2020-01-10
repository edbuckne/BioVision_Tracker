function [P, Idone] = segMembrane(Iws, Imax)
% This function takes in a watershed image (Iws) and a regional max image
% (Imax) (both double) and assigns one regional max per watershed and
% returns the points in P

P = [];
id = 1;
Sws = size(Iws);
Smax = size(Imax);

if ~(Sws==Smax)
    error('Images must be of the same size')
end

Idone = zeros(Sws);  % Image that holds the already done watersheds

[Ix, Iy] = meshgrid(1:Sws(2), 1:Sws(1));

maxPointsx = Ix(logical(Imax));
maxPointsy = Iy(logical(Imax));

for i = 1:length(maxPointsx)
    x = maxPointsx(i);
    y = maxPointsy(i);
    if (Idone(y, x)==0)&&(Iws(y, x)>0) % Meaning this is a region and it hasn't been evaluated yet
        poi = Iws(y, x);  % Get the value of this watershed
        Iwsmask = double(Iws==poi);  % Mask out only this watershed
        Imaxmask = Iwsmask.*Imax;  % Get only the regional max points in this watershed
        [~, Ptmp] = calcCxy(Imaxmask);
        P = [P; round(Ptmp), poi, id];
        id = id+1;
        Iws = Iws-Iwsmask.*poi;
        Idone = Idone + Iwsmask.*poi;
    end
end
end

