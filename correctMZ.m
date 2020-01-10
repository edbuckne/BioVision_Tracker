function correctMZ(spm, tVec, cm)
% correctMZ(spm, tVec, cm) - Allows the user to look at a 3D image of the root and
% choose which z stack is the middle of the root. This is used for greater
% accuracy in BVTmap.m. The 3D image will appear upon calling this
% function. Scroll through the image to find which z-stack you want to use
% as the center. Then type the number of the z-stack into the command line
% and press enter.
% Inputs
%   spm (int) - Number of the specimen to be evaluated.
%   tVec (vec int) - Vector of time stamps to do this for.
%   cm (int) - Number of the microscope channel to be evaluated.

spmStr = ['SPM' num2str(spm, '%.2u')]; % String for specimen directory
for t = tVec
    load([spmStr '/MIDLINE/ml' num2str(t, '%.4u')]);
    I = microImInputRaw(spm, t, cm, 1); % Load image
    f = figure;
    imshow3D(spreadPixelRange(I));
    mZ = input('Which z stack is the center of the root?'); % Prompt the user to input data
    close(f);
    save([spmStr '/MIDLINE/ml' num2str(t, '%.4u')], 'S', 'mZ');
end
end

