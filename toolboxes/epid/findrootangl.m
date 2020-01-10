function [angl] = findrootangl(immask)
% finds the rotation of the image

immaskfilt = imgaussfilt(double(immask), 50);  % Solve for the orientation of the root
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

