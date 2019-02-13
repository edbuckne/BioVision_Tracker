function correctTipLoc( spm, tRange)
% correctTipLoc.m - allows the user to manually correct where the tip of
% the root was indicated.
% Inputs:
%   spm (int) - Specimen number to correct 
%   tRange (vec int) - Time stamps to correct the tip location

cd(['SPM' num2str(spm, '%.2u')]);

if exist('tipTrack.mat')
    load('tipTrack.mat');
else
    error('Must have ran showTipTrack.m');
end

for t = tRange
    I = microImInputRaw(spm, t, 2, 1);
    f = figure;
    imshow(max(I, [], 3));
    hold on
    scatter(tipLoc(t, 1), tipLoc(t, 2));
    [x, y] = ginput(1);
    tipLoc(t, :) = round([x, y]);
    close(f)
end
save('tipTrack', 'delShift', 'tipLoc');
cd ..
end

