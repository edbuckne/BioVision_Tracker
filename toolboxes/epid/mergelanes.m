function [epidLanes] = mergelanes(lanes, xPix)
% Merges the lanes that are close together

epidLanes = lanes; % Holds the detected epidermal lanes
epidN = length(epidLanes);

iterate = true; % Logical variable telling whether or not iteration is still active
Ntmp = epidN; % Recounts the number of epidermal lanes
mergedLanes = zeros(epidN, 1); % Stores a 1 for lanes that are now merged with another lane
while iterate
    iterate = false;
    for i = 1:epidN % Compare each lane to another lane
        lane1 = epidLanes{i};
        
        for j = (i+1):epidN
            if (mergedLanes(i) == 1)||(mergedLanes(j)==1) % Don't consider a lane that has already been merged
                continue;
            end
            
            lane2 = epidLanes{j};
            
            ol = 0;
            for k = 1:size(lane1, 1) % Make sure they are not overlapping too much
                laneol = sum(double(lane2(:, 2) == lane1(k, 2)));
                if laneol>0
                    ol = ol + 1;
                end
            end
            pol = ol./size(lane1, 1);
            if pol>0.1 % Overlapping 10% is too much to merge
                continue;
            end
            
            D = pdist2(lane1, lane2) .* xPix; % Find the minimum distance between points on lanes
            minD = min(D(:));
            
            if minD < 5 % These must be merged
                mergedLanes(j) = 1; % Mark this lane as a merged lane
                iterate = true;
                
                newLane = [];
                miny = [min(lane1(:, 2)), min(lane2(:, 2))];
                maxy = [max(lane1(:, 2)), max(lane2(:, 2))]; % Find the lane on top
                if miny(1) < miny(2)
                    toplane = 1;
                else
                    toplane = 2;
                end
                
                for k = miny(toplane):maxy(3-toplane)
                    lane1y = (lane1(:, 2)==k); % Find all points with this y coordinate
                    lane2y = (lane2(:, 2)==k);
                    
                    newx = round(mean([lane1(lane1y, 1); lane2(lane2y, 1)])); % Get new x coordinate by finding the mean
                    if isnan(newx)
                        continue;
                    end
                    newLane = [newLane; newx, k]; % Append the list
                end
                
                epidLanes{i} = newLane; % New lane replaces one of the lanes
                epidLanes{j} = (epidLanes{j} .* 0) - 1; % Erase old lane with -1's
            end
        end
    end
end

epidLanestmp = epidLanes; % Construct a new epidLanes variable
epidLanes = cell(0);
for i = 1:length(epidLanestmp)
    if epidLanestmp{i}(1, 1)==-1
        continue;
    else
        epidLanes{end+1} = epidLanestmp{i};
    end
end
end

