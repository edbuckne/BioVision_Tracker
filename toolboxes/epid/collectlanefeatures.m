function [X] = collectlanefeatures(lanes, imtip, immask, angl, xPix)
% collects the features necessary to detect epidermal cell files in an SVM
% model.

X = zeros(length(lanes), 3); % Holds the features

imtip = imrotate(imtip, angl); % Get the tip map
imask = imrotate(double(immask), angl); % Get the mask
maskdist = bwdist(1-imask);

for j = 1:length(lanes) % Go through each lane
    thislane = lanes{j}; % Only consider areas above the qc
    qcdist = zeros(size(thislane, 1));
    eddist = zeros(size(thislane, 1));
    for k = 1:length(qcdist)
        qcdist(k) = imtip(thislane(k, 2), thislane(k, 1));
        eddist(k) = maskdist(thislane(k, 2), thislane(k, 1));
    end
    aboveqc0 = thislane(qcdist>0, :);
    eddist = eddist(qcdist>0) .* xPix;
    if isempty(aboveqc0)
        continue;
    end
    
    xpos = aboveqc0(:, 1); % Gather the location of each point in microns
    xposmicron = xpos .* xPix;
    
    xposstdev = sqrt(var(xposmicron)); % (1) Standard deviation of x position in microns
    bwdistmean = mean(eddist); % (2) Average distance away of mask edge in microns
    lanelength = (max(thislane(:, 2))-min(thislane(:, 2))).*xPix; % (3) Y range of lane in microns
    
    X(j, :) = [xposstdev, bwdistmean, lanelength];
end

end

