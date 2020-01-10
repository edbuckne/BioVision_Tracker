function EPIDtransition(SPM, varargin)
% EPIDtransitiont.m is a function at the highest level of the epid toolbox. This
% function takes in the specimen and detects the estimated location of the
% transition zone. Must have ran BVTreconstruct/BVTreconstructunet,
% EPIDqcdist, and EPIDdetect.

defaultTimeSetting = 'all';
defaultTransitionZoneModel = 'model_of_cell_size_transition_zone';
defaultPlotSetting = false;
defaultTimeRange = 1;

expectedTimeSetting = {'all', 'spec'};

p = inputParser();
addRequired(p, 'SPM');  % The number of the specimen
addParameter(p, 'TimeRange', defaultTimeRange);  % Only read if the 'TimeSetting' is set to 'spec'. Tells which time stamps to evaluate
addParameter(p, 'TransitionZoneModel', defaultTransitionZoneModel);  % The name of the transition zone model that holds the parameters for the gamma distribution
addParameter(p, 'PlotSetting', defaultPlotSetting, ...
    @(x) islogical(x));  % true: plot the results, false: don't plot the results
addParameter(p, 'TimeSetting', defaultTimeSetting, ...
    @(x) any(validatestring(x, expectedTimeSetting)));  % 'all' means all time stamps will be evaluated and 'spec' means a range has been specified

parse(p, SPM, varargin{:});

load('./data_config.mat');

spm = SPM;
sInd = find(tSpm(:, 1)==SPM);  % Find the index of this specimen in the tSpm matrix

if strcmp(p.Results.TimeSetting, 'all')  % Indicate whether the user specifies a time range
    tRange = tSpm(sInd, 2):tSpm(sInd, 3);
else
    tRange = p.Results.TimeRange;
end

spmdir = ['SPM' num2str(SPM, '%.2u')]; % Specimen directory

load(p.Results.TransitionZoneModel);  % Load the gamma distribution parameters

for i = 1:length(tRange) % Go through all time stamps
    t = tRange(i);  % Get the time stamp
    
    try
        load([spmdir '/EPID/ep' num2str(t, '%.4u')]);
        load([spmdir '/EPID/qc' num2str(t, '%.4u')]);
        load([spmdir '/MIDLINE/ml' num2str(t, '%.4u')]);
        load([spmdir '/tipTrack.mat']);
    catch
        warning('You are missing one or more files, terminating EPIDtransition.m');
        return;
    end
    
    yS = tipLoc(2);  % Create an image that shows the distances from the qc
    Itip = createtipmap(spm, 1, S, yS);
    Imask = showMask(spm, 1, false);
    
    imS = size(Imask);
    
    Plane1 = zeros(length(Pepid), 1);
    Plane2 = zeros(length(Pepid), 1);
    for k = 1:size(P, 1)  % Go through each cell
        if Pepid(k) == 0  % If it is not a detected cell, go on
            continue
        end
        rotP = rotatepointimage(zeros(imS), P(k, 1:2), angl);
        ptmp = pdist2(rotP, epidlanes{1});  % Find the lane this attests to
        min1 = min(ptmp(:));
        ptmp = pdist2(rotP, epidlanes{2});
        min2 = min(ptmp(:));
        [~, lind2] = min([min1, min2]);
        
        if lind2 == 1  % Add this cell if it is closest to the lane we are taking into consideration
            Plane1(k) = 1;
        elseif lind2 == 2
            Plane2(k) = 1;
        end
    end
    
    [A1, B1, C1, fhand1] = modelqcregression(QC(Pepid(:, 2) == 1), X(Pepid(:, 2) == 1, 2), ...
        'RegressionModel', 'exponential');  % Model the regression of cell size vs. qc distance
    [A2, B2, C2, fhand2] = modelqcregression(QC(Pepid(:, 2) == 2), X(Pepid(:, 2) == 2, 2), ...
        'RegressionModel', 'exponential');
    
    Itipmask = Itip .* Imask;  % Create two heatmaps that are blank right now
    heatmap1 = Itipmask;
    heatmap2 = Itipmask;
    
    for row = 1:imS(1)  % Fill in the value for the gamma distribution according to both lane models
        for col = 1:imS(2)
            if Itipmask(row, col) == 0
                continue;
            end
            heatmap1(row, col) = gampdf(fhand1(A1, B1, C1, Itipmask(row, col)), phat(1), phat(2));
            heatmap2(row, col) = gampdf(fhand2(A2, B2, C2, Itipmask(row, col)), phat(1), phat(2));
        end
    end
    
    hmfilt1 = spreadPixelRange(imgaussfilt(heatmap1, 3));  % Create the rgb heatmaps with filtering
    hmfilt2 = spreadPixelRange(imgaussfilt(heatmap2, 3)); 
    rgbmask = cat(3, Imask, Imask, Imask);
    rgbhm1 = cat(3, hmfilt1, zeros(imS), 1-hmfilt1).*rgbmask;
    rgbhm2 = cat(3, hmfilt2, zeros(imS), 1-hmfilt2).*rgbmask;
    
    if p.Results.PlotSetting  % Plot if the user specifies
        figure
        imshow(rgbhm1);
        figure
        imshow(rgbhm2);
    end
    
    [~, maxpoint1] = max(rgbhm1(:));  % Find the estimated distance from the qc 
    [~, maxpoint2] = max(rgbhm2(:));

% ~~~~~~~~~~~~~~~~~~~~Trying multi-strucure~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
%     x1 = QC(Pepid(:, 2) == 1);
%     P1 = P(Pepid(:, 2) == 1, :);
%     y1 = X(Pepid(:, 2) == 1);
%     x2 = QC(Pepid(:, 2) == 2);
%     P2 = P(Pepid(:, 2) == 2, :);
%     y2 = X(Pepid(:, 2) == 2);
%     
%     [~, bp1] = strucBreakPoint1(x1, y1);
%     [~, bp2] = strucBreakPoint1(x2, y2);
% 
%     qctz = [Itipmask(P1(bp1(1), 2), P1(bp1(1), 1)); Itipmask(P2(bp2(1), 2), P2(bp2(1), 1))]; 
%     save([spmdir '/EPID/tz' num2str(t, '%.4u')], 'qctz');

    qctz = [Itipmask(maxpoint1), Itipmask(maxpoint2)];
    
    save([spmdir '/EPID/tz' num2str(t, '%.4u')], 'rgbhm1', 'rgbhm2', 'qctz', 'A1', 'B1', 'C1', 'fhand1', 'A2', 'B2', 'C2', 'fhand2');
    
    imwrite(rgbhm1, [spmdir '/EPID/hm' num2str(t, '%.4u') '_01.tif']);
    imwrite(rgbhm2, [spmdir '/EPID/hm' num2str(t, '%.4u') '_02.tif']);
end
end

