function [angl] = calcUprightRotation(Imask)
% calcUprightRotation.m takes in a mask image of a root and determines what
% angle it needs to be rotated to be straight up and down.

Imask = imresize(im2double(Imask), [512, 512]);
immaskfilt = imgaussfilt(double(Imask), 50);  % 50 works good for a 512x512 image
O = -90:5:90;
C = zeros(length(O), 1);
Vy = zeros(length(O), 1);
for o = 1:length(O)
    deg = O(o);
    C(o) = calcCxy(imrotate(immaskfilt, deg));  % The covariance of the upright root is 0
    [~, Vy(o)] = calcVxVy(imrotate(immaskfilt, deg));  % It is upright when Vy is at a maximum
end
fromzero = abs(C);
locminind = islocalmin(fromzero);
Vyatlocmin = Vy .* double(locminind);
[~, angind] = max(Vyatlocmin);
angl = O(angind);
end

