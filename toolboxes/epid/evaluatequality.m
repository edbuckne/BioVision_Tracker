function [qualavg] = evaluatequality(spm, t, epidLanes)
spmdir = ['SPM' num2str(spm, '%.2u')]; % load the lane data
surrPix = 10;
lanespath = [spmdir '/EPID/lanes' num2str(t, '%.4u') '.mat'];
cellpath = [spmdir '/EPID/cells' num2str(t, '%.4u') '.mat'];
savefile = [spmdir '/EPID/qual' num2str(t, '%.4u') '.mat'];
if exist(cellpath, 'file')
    load(lanespath);
    load(cellpath);
else
    qualavg = NaN;
    return;
end

imzrot = spreadPixelRange(imrotate(1-imz, angl)); % Rotate the image to visualize
qual = zeros(2, 1);

d = []; % Holds the pixel data from this image
for l = 1:length(epidLanes)
    for j = 1:size(epidLanes{l}, 1) % Collect pixel data
        if cwidx{l}(j)==1 % Cell wall
            surr = zeros(2.*surrPix, 1); % Holds surrounding data
            count = 1;
            for i = -surrPix:surrPix % Gather average surrounding data
                if i==0
                    continue;
                else
                    if ((j+i)<=0)||((j+i)>=size(epidLanes{l}, 1))
                        surr(count) = NaN;
                    else
                        surr(count) = imzrot(epidLanes{l}(j+i, 2), epidLanes{l}(j+i, 1));
                    end
                    count = count + 1;
                end
            end
            surr = surr(~isnan(surr)); % Don't consider NaN cases
        else
            continue;
        end
        d = [d; imzrot(epidLanes{l}(j, 2), epidLanes{l}(j, 1))./mean(surr)];
    end
    
end

qualavg = mean(d); % Get the average of the 2 cell files
end

