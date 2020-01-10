function [celllength] = epidmeasurecelllength(epidlanes, Iout, angl, P, Pepid)
% epidmeasurecelllength.m takes in the information gathered in epidpredict
% and measures (in microns) the longitudinal length of each cell that was 
% found in the epidermal cell files.

load('data_config', 'xPix'); % Get the resolution of each XY pixel
Ioutangl = imrotate(Iout, angl); % Rotate the segmented image to line up with the lanes

lanemask = zeros(size(Ioutangl, 1), size(Ioutangl, 2), 2); % Holds a mask containing the locations of the lanes
for l = 1:2
    for j = 1:size(epidlanes{l}, 1)
        lanemask(epidlanes{l}(j, 2), epidlanes{l}(j, 1), l) = 1;
    end
end
% lanemask(epidlanes{1}(:, 2), epidlanes{1}(:, 1), 1) = 1;
% lanemask(epidlanes{2}(:, 2), epidlanes{2}(:, 1), 2) = 1;

[~, ygrid] = meshgrid(1:size(Ioutangl, 2), 1:size(Ioutangl, 1)); % Image that holds the xy locations

cellcount = size(P, 1); % Number of segmented cells
celllength = zeros(cellcount, 2); % Holds the length of the cells
for i = 1:cellcount % Go through each detected cell
    if Pepid(i) == 0 % Don't care about the non-epidermal cells
        continue;
    else
        segval = P(i, 3); % Mask that cell in the segmented image
        Icellmask = double(Ioutangl == segval); 
        celllength(i, 2) = sum(Icellmask(:)).*xPix.^2; % Size of the cell
        
        Imastermask = Icellmask.*lanemask(:, :, Pepid(i, 2)).*ygrid; % Mask all combinations together
        ypos = Imastermask(Imastermask>0);
        
        ymax = max(ypos); ymin = min(ypos); % Measure the length
        celllength(i, 1) = (ymax-ymin).*xPix;
    end
end
end

