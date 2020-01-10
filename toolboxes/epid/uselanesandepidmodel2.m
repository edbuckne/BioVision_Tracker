function [epidLogical, epidlanes] = uselanesandepidmodel2(lanes, Iout, Imask, angl, P)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
load('data_config', 'xPix');
Sim = size(Iout);
Ibwdist = bwdist(1-imrotate(Imask, angl)).*xPix; % Get the image that shows how far away a region is from a boundary
epidLogical = zeros(size(P, 1), 2); % Holds the labels for what has been indicated as the epidermal cells, and which epid lane it belongs to
checkedgeimage = zeros(Sim); % Used to check if any segmented cell is found at the edge of an image
[xim, yim] = meshgrid(1:Sim(2), 1:Sim(1)); % Holds the x and y positions

Nlanes = length(lanes); % Find the number of lanes that is not empty
for i = 1:Nlanes
    if isempty(lanes{i})
        Nlanes = i - 1;
        break;
    end
end
bwavg = zeros(Nlanes, 3); % Holds the average bwdistance for that lane

IoutRot = imrotate(Iout, angl); % Rotate the segmented image to align with the lanes
for i = 1:Nlanes % Go through each definition of a lane
    thislane = lanes{i};
    lanecellcount = 0; % The count of cells found in this lane
    lanecellsum = 0; % The sum of the bw distance in this lane
    
    for j = 1:size(thislane, 1) % Go through each point in this lane
        row = thislane(j, 2); % Grab the segmentation value associated with this point
        col = thislane(j, 1);
        segval = IoutRot(row, col);
        
        if segval == 0 % No associated cell here
            continue;
        else
            cellMask = IoutRot == segval; % Find the BW distance value of this cell
            [~, Mu] = calcCxy(cellMask);
            bwdistval = Ibwdist(round(Mu(2)), round(Mu(1)));
            
            lanecellcount = lanecellcount + 1; % Update the values for this lane
            lanecellsum = lanecellsum + bwdistval;
            
            IoutRot = IoutRot - cellMask .* segval; % Erase this cell from the segmented image
        end
    end
    bwavg(i, 1) = lanecellsum./lanecellcount; % Average bwdistance value
    bwavg(i, 2) = lanecellcount; % Number of cells found here
    bwavg(i, 3) = i; % Lane index
end
[B, idxcc] = sort(bwavg(:, 1), 'ascend'); % Sort the list from smallest to largest

epidlanes = cell(2, 1);
ii = 1;
for i = 1:length(B) % Find the 2 cell files to use for the epidermis
    ncellsforB = bwavg(idxcc(i), 2); % Ensure this lane has X number of cells
    if ncellsforB > 15
        epidlanes{ii} = lanes{idxcc(i)};
        ii = ii + 1;
        if ii == 3
            break;
        end
    end
end

IoutRot = imrotate(Iout, angl); % Rotate the segmented image to align with the lanes
for i = 1:2 % Just go through the 2 epidermal lanes right now
    thislane = epidlanes{i};
    
    for j = 1:size(thislane, 1) % Go through each point in this lane
        row = thislane(j, 2); % Grab the segmentation value associated with this point
        col = thislane(j, 1);
        segval = IoutRot(row, col);
        
        if segval == 0 % No associated cell here
            continue;
        else
            
            checkedgeimagey = double(Iout == segval) .* yim; % Do not consider a cell found at the edge of an image
            edgeylist = checkedgeimagey(checkedgeimagey>0);
            checkedgeimagex = double(Iout == segval) .* xim;
            edgexlist = checkedgeimagex(checkedgeimagex>0);
            if (max(edgeylist)==Sim(1)) || (min(edgeylist)==1) || (max(edgexlist)==Sim(2)) || (min(edgexlist)==1)
                continue;
            end
            
            segvalfound = P(:, 3) == segval; % Label this as an epidermal cell and note which lane it belongs to
            epidLogical(segvalfound, 1) = 1;
            epidLogical(segvalfound, 2) = i;
            
            cellMask = IoutRot == segval; % Find the segmentation value         
            IoutRot = IoutRot - cellMask .* segval; % Erase this cell from the segmented image
        end
    end
end
end

