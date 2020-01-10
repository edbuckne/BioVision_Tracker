function [X, Y] = collectDataset(loadName, saveName, features, man, spm, t)
% collectDataset.m takes in the name of a saved manual labelling session
% completed by labelPoints.m. Data is collected of each of these labels,
% but only the features (specified by the features variable) are collected
% into the dataset. The list below shows all available features to use.
%   1. Shape of region
%   2. QC/Tip Distance
%   3. Distance from the center
%   4. Distance to nearest neighbor
%   5. # of regions in the same file (phloem specific)
%   6. # of regions closer to the QC/Tip

if man  % Just returns the modified X variable
    [clInfo, timeArray] = loadclInfo(spm);
    ta = timeArray(t, 1):timeArray(t, 2);
    cylCoord = loadcylCoord(spm);
    [shapeInfo, statsTot] = loadshape_info(spm);
    
    I = microImInputRaw(spm, t, 1, 1);
    
    if exist(['SPM' num2str(spm, '%.2u') '/elongationIndex.mat'])
        load(['SPM' num2str(spm, '%.2u') '/elongationIndex.mat']);
        eiMat = true;
    else
        eiMat = false;
    end
    
    cSize = sum(clInfo(:, 10)==t);
    X = zeros(cSize, 6);
    Y = zeros(cSize, 2);
    
    for i = 1:length(ta)
        if eiMat
            X(i, 1) = ei(ta(i));
        else
            X(i, 1) = elongationIndex(spm, ta(i), I);  % Collect Data
        end
        % X(i, 1) = shapeInfo(ta(i), 4);
        X(i, 2) = cylCoord(ta(i), 1);
        X(i, 3) = cylCoord(ta(i), 2);
        X(i, 4) = closestNeighborDistance(spm, ta(i));
        X(i, 5) = sameFileNumber(spm, ta(i), [5, 0.1]);
        X(i, 6) = cellsBelowNumber(spm, ta(i));
    end
    X = X(:, features);
else
    j = 1;  % Index for the dataset
    
    load('data_config.mat');  % Load the necessary data
    load(loadName);
    
    dataSetSize = size(dataPos, 1)+size(dataNeg, 1);  % Initialize dataset variables
    X = zeros(dataSetSize, 6);
    Y = zeros(dataSetSize, 2);
    
    for spmInd = 1:length(tSpm(:, 1))  % Run through each specimen
        tic;
        spm = tSpm(spmInd, 1);  % Gather information about this specimen
        [clInfo, timeArray] = loadclInfo(spm);
        cylCoord = loadcylCoord(spm);
        
        disp(['Loading specimen ' num2str(spm) ' data ...']);
        
        I = microImInputRaw(spm, 1, 1, 1);  % Load 3D fluorescent image
        
        posInd = dataPos(:, 1) == spm;  % Find the indices from this specimen in the labeled data
        posIndMat = dataPos(posInd, 2);
        negInd = dataNeg(:, 1) == spm;
        negIndMat = dataNeg(negInd, 2);
        indLabels = [posIndMat, ones(length(posIndMat), 1); ...
            negIndMat, ones(length(negIndMat), 1).*2];
        
        if exist(['SPM' num2str(spm, '%.2u') '/elongationIndex.mat'])
            load(['SPM' num2str(spm, '%.2u') '/elongationIndex.mat']);
            eiMat = true;
        else
            eiMat = false;
        end
        
        for i = 1:size(indLabels, 1)  % Go through each region in this specimen
            try
                if eiMat
                    X(j, 1) = ei(indLabels(i, 1));
                else
                    X(j, 1) = elongationIndex(spm, indLabels(i, 1), I);  % Collect Data    
                end
                X(j, 2) = cylCoord(indLabels(i, 1), 1);
                X(j, 3) = cylCoord(indLabels(i, 1), 2);
                X(j, 4) = closestNeighborDistance(spm, indLabels(i, 1));
                X(j, 5) = sameFileNumber(spm, indLabels(i, 1), [5, 0.1]);
                X(j, 6) = cellsBelowNumber(spm, indLabels(i, 1));

                Y(j, indLabels(i, 2)) = 1;  % One hot label

                j = j+1;  % Increment index
            catch
                continue;
            end
        end
        
        tEval = toc;
        disp(['Data collection time: ' num2str(tEval)]);
    end
    
    X = X(1:j-1, features);  % Trim data to just the features the user specified
    Y = Y(1:j-1, :);
    save(saveName, 'X', 'Y', 'features');
end
end

