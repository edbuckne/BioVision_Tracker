function [P, Iout, ang] = segmentCells(spm, t, cm, z, upright, Iin)
% This function segments plant cells from confocal images that are
% configured in the BVT filing format. The cell walls must be stained and
% be darker than the cells themselves (eg. negative of raw image)

ydata = [50, 450];
wdata = [51, 11];
thdata = [0.45, 0.7];
maskpct = 40;

% wdata = [71, 21];
% maskpct = 75;

% Loading the image
if exist('Iin', 'var')
    I = Iin;
elseif ~upright
    I3D = microImInputRaw(spm, t, cm, 1);
    I = I3D(:, :, z);
    ang = 0;
else
    [I, ang] = imturnupright(spm, t, cm, z);
end

% Filter the image and run adaptive threshold
Ifilt1 = imgaussfilt(I, 1);
Igrad = imgradient(Ifilt1);
Inew = (((1-spreadPixelRange(Igrad)) + spreadPixelRange(Ifilt1))./2);
% Iath = adaptthresh2(Ifilt1, 31, 0.7);
% Iath = adaptthresh2(Inew, 31, 0.5);
Iath = actadaptthresh(Ifilt1, ydata, thdata, wdata);
D = bwdist(Iath);
if upright
    Imask = imrotate(showMask(spm, t, false), ang);
else
    Imask = showMask(spm, t, false);
end
% Imask = pctth(imgaussfilt(I, 3), maskpct);

Iws = im2double(watershed(D));
Iwsmask = Iws.*Imask;
Iout = Iwsmask;

Imax = imregionalmax(imgaussfilt(Iath, 2));

% Grab the center of mass points for each detectable cell
[P, ~] = segMembrane(Iwsmask, Imax);
ang = 0;
% figure;
% imshow(I)
% hold on
% scatter(P(:, 1), P(:, 2))
end
% % Indicate the cells to evaluate
% h = imfreehand('Closed', false);
% Pline = round(h.getPosition);
% close all
% 
% % Select the cells from the Iws image
% Iw = Iwsmask;
% S = size(Iw);
% 
% trimmedP = [];
% 
% for i = 1:size(Pline, 1)
%     if Iw(Pline(i, 2), Pline(i, 1))>0
%         poi = Iw(Pline(i, 2), Pline(i, 1));
%         findP = P((P(:, 3)==poi), :);
%         trimmedP = [trimmedP; findP];
%         Iw = Iw - poi.*double(Iw==poi);
%     end
% end
% 
% figure
% imshow(I)
% hold on
% scatter(trimmedP(:, 1), trimmedP(:, 2))
% Iws = Iws.*Imask;
% end

