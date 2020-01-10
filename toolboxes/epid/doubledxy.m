function [igradx1, igradx2, igrady1, igrady2] = doubledxy(iup, sigma)
% doubledxy(iup, sigma) - finds the first and second gradient of the image
% sent as a double (iup). The sigma input is used as a smoothing parameter
% on the image (sigma [default = 2]).
if ~exist('sigma', 'var')
    sigma = 2;
end

iupfilt = imgaussfilt(iup, sigma); % Gather the second derivative in both directions
[igradmag1, igraddir1] = imgradient(iupfilt);
igradx1 = igradmag1 .* cosd(igraddir1);
igrady1 = igradmag1 .* sind(igraddir1);
clear('igradmag1'); clear('igraddir1');
[igradxmag2, igradxdir2] = imgradient(igradx1);
[igradymag2, igradydir2] = imgradient(igrady1);
igradx2 = igradxmag2 .* cosd(igradxdir2);
igrady2 = igradymag2 .* sind(igradydir2);
end

