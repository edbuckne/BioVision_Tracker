function [f] = showCellBoundaries(spm, t)
% Prints an image of the indicated epidermal cell boundaries in the EPID
% directory.
spmDir = ['SPM' num2str(spm, '%.2u')];
load([spmDir '/EPID/ep' num2str(t, '%.4u')]);

Ioutangl = imrotate(Iout, angl); % Rotate the segmented image to line up with the lanes

lanemask = zeros(size(Ioutangl, 1), size(Ioutangl, 2), 2); % Holds a mask containing the locations of the lanes
for l = 1:2
    for j = 1:size(epidlanes{l}, 1)
        lanemask(epidlanes{l}(j, 2), epidlanes{l}(j, 1), l) = 1;
    end
end

[xgrid, ygrid] = meshgrid(1:size(Ioutangl, 2), 1:size(Ioutangl, 1)); % Image that holds the xy locations
xypoints = [];

cellcount = size(P, 1); % Number of segmented cells
for i = 1:cellcount % Go through each detected cell
    if Pepid(i) == 0 % Don't care about the non-epidermal cells
        continue;
    else
        segval = P(i, 3); % Mask that cell in the segmented image
        Icellmask = double(Ioutangl == segval); 
        
        Imastermask = Icellmask.*lanemask(:, :, Pepid(i, 2)).*ygrid; % Mask all combinations together
        ypos = Imastermask(Imastermask>0);
        Imastermaskx = Icellmask.*lanemask(:, :, Pepid(i, 2)).*xgrid;
        xpos = Imastermaskx(Imastermask>0);
        
        [ymax, maxi] = max(ypos); ymin = min(ypos); % Measure the length
        xypoints = [xypoints; xpos(maxi), ymax];
    end
end

f = figure;
imshow(imrotate(imz, angl));
hold on
scatter(xypoints(:, 1), xypoints(:, 2), '.r');

saveas(f, [spmDir '/EPID/cb' num2str(t, '%.2u') '.tif']);
end

