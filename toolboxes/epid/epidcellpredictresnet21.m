function [lanedata, igradx2, igrady2, itipup] = epidcellpredictresnet21(spm, t, imz, angl, epidLanes, varargin)
% epidcellpredictresnet21(spm, t, imz, angl, epidLanes, varargin) - predicts the points in
% epidLanes in which cell boundaries are detected.
% Inputs:
%   spm (int) - specimen identifier
%   t (int) - time stamp to evaluate
%   imz (NxM double) - image to evaluate (dark foreground assumed)
%   angl (int) - angle to rotate imz to get an upright root

M = 21;
L = (M-1)/2;

itip = tipmap(spm, t); % Holds the distance from the qc/tip

Irot = imrotate(imz, angl); % Rotate the images
itipup = imrotate(itip, angl);

[~, igradx2, ~, igrady2] = doubledxy(Irot, 2); % Find the second derivate gradient of the image

load('resnet21', 'trainedNet');

lanedata = cell(length(epidLanes), 1);
for i = 1:length(epidLanes) % Go through each epidermal lane
    thislane = epidLanes{i};
    imds = uint8(zeros(M, M, 3, size(thislane, 1)));
    for j = 1:size(thislane, 1)
        lxy = epidLanes{i}(j, :);
        try
            litI = im2uint8(Irot((lxy(2)-L):(lxy(2)+L), (lxy(1)-L):(lxy(1)+L)));
        catch
            continue;
        end
        
        imds(:, :, :, j) = cat(3, litI, litI, litI);
    end
    
    [~, sc] = classify(trainedNet, imresize(imds, [224, 224]));
    poslabel = sc(:, 2)>0.5; % Can adjust the sensitivity for cell wall detection here
    poslabel = islocalmax(filtfilt(ones(1, 5)./5, 1, double(poslabel)));
    lanedata{i} = double(poslabel);
end
end

