function correctTipLoc( spm, tVec, cm)
% correctTipLoc(spm, tVec) - allows the user to manually correct where the tip of
% the root was indicated. The 3D image of this root will appear. Scroll to
% the z-stack that you desire, press enter, and then click the point in
% which you want to measure longitudinally from.
% Inputs:
%   spm (int) - Specimen number to correct 
%   tVec (vec int) - Time stamps to correct the tip location
%   cm (int) - Number of the microscope channel to be evaluated.

cd(['SPM' num2str(spm, '%.2u')]);

if exist('tipTrack.mat')
    load('tipTrack.mat');
else
    % error('Must have ran showTipTrack.m');
    tipLoc = zeros(length(tVec), 2);
    delShift = 0;
end

for t = tVec
    I = 1-microImInputRaw(spm, t, cm, 1);
    f = figure;
    % imshow(max(I, [], 3));
    imshow3D(I)
    input('Find the z-stack you want to annotate and press enter: ');
    hold on
    scatter(tipLoc(t, 1), tipLoc(t, 2));
    [x, y] = ginput(1);
    tipLoc(t, :) = round([x, y]);
    close(f)
end
save('tipTrack', 'delShift', 'tipLoc');
cd ..
end

