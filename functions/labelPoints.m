function labelPoints(spmVec, saveName)
% labelPoints.m takes in the specimen indicated in the specimen vector
% variable (spmVec) and prompts the user to indicate the points that are of
% a positive label. Those labels, along with the specimen number, and
% identifiers of each label (positive and negative) are saved to a .mat
% file with the name specified in the saveName variable.

load data_config
dataPos = [];
dataNeg = [];
for spm = spmVec
    disp(['SPM' num2str(spm, '%.2u')]);
    ii = tSpm(:, 1)==spm;
    tRange = tSpm(ii, 2):tSpm(ii, 3);
    for t = tRange
        I = microImInputRaw(spm, t, 1, 1);  % Load 3d image
        
        [clInfo, timeArray] = loadclInfo(spm);
        indMat = getIndMat(spm, t);
        iRange = timeArray(t, 1):timeArray(t, 2);  % Collect the 2D points to plot on the max projection
        xyPoints = clInfo(iRange, 1:2);
        
        Imax = spreadPixelRange(max(I, [], 3));  % Plot the max projection with points superimposed
        figure
        imshow(1-Imax)
        hold on
        scatter(xyPoints(:, 1), xyPoints(:, 2))
        [x, y] = ginput(100);
        close all
        
        chosenpoints = zeros(length(x), 1);  % Notes the connections of user identified and software identified
        M = distmatrix2d(xyPoints, [x, y]);
        
        for i = 1:size(M, 2)
            [~, id] = min(M(:, i));
            chosenpoints(i) = id + timeArray(t, 1) - 1;  % Notes the id of the chosen points and makes a connection
        end
        
        dataPos = [dataPos; ones(length(x), 1).*spm, chosenpoints, ones(length(x), 1)];
        
        findArray = indMat==chosenpoints;
        findArraySum = sum(findArray, 1);
        notChosenpoints = indMat(findArraySum==0);
        dataNeg = [dataNeg; ones(length(notChosenpoints), 1).*spm, notChosenpoints', ones(length(notChosenpoints), 1).*2];
    end
end

save(saveName, 'dataPos', 'dataNeg');
end

