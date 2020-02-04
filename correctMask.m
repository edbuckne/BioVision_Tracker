function correctMask(spm, tVec, cm)
% correctMask(spm, tVec, varargin) - Allows the user to manually create a structural mask of
% the organism.
% Inputs
%   spm (int) - Number of the specimen
%   tVec (int vec) - List of time stamps to correct
%   cm (int) - Camera to be evaluated. Default is camera 2.
% Outpus
%   None

load('data_config');

for t = tVec % Go through the vector of time points to correct
    I = microImInputRaw(spm, t, cm, 1); % Take in the image
    % Imask = roipoly(spreadPixelRange(max(I, [], 3)));
    figure
    imshow(spreadPixelRange(max(I, [], 3)));
    h = imfreehand;
    Imask = h.createMask();
    close all
    f = figure;
    imshow(Imask);
    
    [~, Y] = meshgrid(1:size(I, 2), 1:size(I, 1));
    Ymask = double(Imask).*Y;
    Ytip = max(Ymask(:));
    x = 1:size(Imask, 2); % Finding the midline using the concept of expected value in a uniform distribution
    Ymid = zeros(Ytip, 1);
    for row = 1:Ytip
        integ = sum(double(Imask(row, :)));
        expOut = sum(x.*double(Imask(row, :))./integ);
        Ymid(row) = round(expOut);
    end
%     if length(Ymid)<300
%         S = [];
%         Imask = Imask.*0;
%         return;
%     end
    S = Ymid; 
    hold on
    plot(S, 1:length(S));
    mZ = round(size(I, 3)/2);
    
    if ~exist(['SPM' num2str(spm, '%.2u') '/MIDLINE'])
        mkdir(['SPM' num2str(spm, '%.2u') '/MIDLINE'])
    end
    save(['SPM' num2str(spm, '%.2u') '/MIDLINE/ml' num2str(t, '%.4u')], 'S', 'mZ');
    imwrite(Imask, ['SPM' num2str(spm, '%.2u') '/MIDLINE/mask' num2str(t, '%.4u') '.tif']);
end
end

