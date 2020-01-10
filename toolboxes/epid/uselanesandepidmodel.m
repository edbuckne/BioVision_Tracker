function [epidLogical, epidlanes] = uselanesandepidmodel(lanes, maskcum, Iout, P)
% uselanesandepidmodel.m - takes in the lanes found in lane detection and
% the estimated epidermal cells from the epid model and determines the best
% two file predictions for epidermal cells.

S = size(Iout);
epidLogical = zeros(size(P, 1), 1);
lanesfinal = lanes;
cellcount = zeros(length(lanesfinal), 2);  % Holds the cell counts
    imepid = maskcum;
    for i = 1:length(lanesfinal)  % Go through all lanes
        imactive = Iout;  % How we will be counting the number of cells in this lane
        
        thislane = lanesfinal{i};  % Load a lane of points
        
        for j = 1:size(thislane, 1)
            row = thislane(j, 2);  % Get the segmentation value
            col = thislane(j, 1);
            segval = imactive(row, col);
            
            if segval <= 0
                continue;
            else
                cellcount(i, 1) = cellcount(i, 1) + 1;  % Total number of cells in this lane
                imactive = imactive - 1 .* double(imactive == segval);
                
                epval = imepid(row, col);
                if epval > 0  % This is a detected epidermal cell
                    cellcount(i, 2) = cellcount(i, 2) + 1;
                end
            end
        end
    end
    
    % Find the two lanes for epidermis
    [B, idxcc] = sort(cellcount(:, 2), 'descend');
    epidlanes = {lanesfinal{idxcc(1)}, lanesfinal{idxcc(2)}};
    
    % Create a figure that shows those detected cells
    imblank = zeros(S);
    
    imactive = Iout;  % How we will be counting the number of cells in this lane
    for i = 1:2
        thislane = epidlanes{i};
        for j = 1:size(thislane, 1)
            row = thislane(j, 2);  % Get the segmentation value
            col = thislane(j, 1);
            segval = imactive(row, col);
            
            
            if segval == 0
                continue;
            else
                cellcount(i, 1) = cellcount(i, 1) + 1;  % Total number of cells in this lane
                imblank = imblank + double(imactive == segval);
                imactive = imactive - segval .* double(imactive == segval);
                epidLogical(P(:, 3)==segval) = 1;
            end
        end
    end
    
end

