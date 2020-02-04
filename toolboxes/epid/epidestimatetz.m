function [Xdata, score, cw, qctz, tzpoints] = epidestimatetz(spm, t, varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
defaultTZModel = 'tzMdl';
defaultCollectXData = false;

p = inputParser();
addParameter(p, 'TZModel', defaultTZModel); % The model used for predicting the cell at the TZ/EZ boundary
addParameter(p, 'CollectXData', defaultCollectXData); % If true, the XData from the cell boundaries are saved and the TZ is not estimated

parse(p, varargin{:});

spmdir = ['SPM' num2str(spm, '%.2u')]; % Get paths to files to load
lanePath = [spmdir '/EPID/lanes' num2str(t, '%.4u') '.mat'];
cellPath = [spmdir '/EPID/cells' num2str(t, '%.4u') '.mat'];

if ~exist(lanePath, 'file') % Check if data files are there
    error('No lane file. Must run EPIDlane first')
elseif ~exist(cellPath, 'file')
    error('No cell file. Must fun EPIDcell first');
end

load(lanePath); % Load the data if they are there
load(cellPath);
load(p.Results.TZModel); % Load the model to predict where the tz is
load('./data_config');

features = 3; % Gather features for each point

NepidLanes = length(epidLanes); % Number of epidermal lanes detected
if p.Results.CollectXData
    Xdata = []; % Holds the x data differently if we are just collecting the points
else
    Xdata = cell(NepidLanes, 1); % Holds the features for each point
end
score = cell(NepidLanes, 1); % Holds the scores from the model to predict the TZ
cw = cell(NepidLanes, 1);
qctz = zeros(length(score), 1);
tzpoints = zeros(length(score), 2);
for i = 1:NepidLanes
    cwPoints = epidLanes{i}(cwidx{i}==1, :); % Get the points of the cell walls in the epidermal file
    PlaneMu = cwPoints.*xPix; % Coordinates in microns
    Xtmp = zeros(size(PlaneMu, 1), features); % Holds the features
    [S, si] = sort(PlaneMu(:, 2), 'Descend'); % Sort the points by the y direction (largest to smallest)
    PlaneMu = [PlaneMu(si, 1), S];
    cw{i} = cwPoints(si, :);
    
    PlaneDiff = [0; abs(diff(PlaneMu(:, 2)))]; % Get the derivative and filter
    
    loop = true;
    filtord = 5;
    while (loop)&&(filtord>0)
        try
            b = ones(1, filtord)./filtord;
            PD = filtfilt(b, 1, PlaneDiff);
            loop = false;
        catch
            loop = true;
            filtord = filtord-1;
        end
    end
    PDD = [0; diff(PD)];
    PDDD = [0; diff(PDD)];
    idl = 1:length(PDDD);
    PDDD(idl<=2) = 0;
    cumData = zeros(length(PD), 2);
    for j = 1:size(cwPoints, 1)
        cumData(j, 1) = mean(PD(1:j));
        cumData(j, 2) = sqrt(var(PD(1:j)));
        
        Xtmp(j, 1) = PD(j); % First derivative
        Xtmp(j, 2) = PDD(j); % Second derivative
        Xtmp(j, 3) = (PD(j)-cumData(j, 1))./cumData(j, 2); % Normalized to all cells before
%         if j==1
%             continue;
%         else
%             Xtmp(j, 4) = PD(j)./PD(j-1);
%         end
    end
%     Xtmp(idl<=10, 4) = 0;
    if p.Results.CollectXData
        Xdata = [Xdata; Xtmp]; % We are just collecting the data now
        score = [];
        qctz = [];
        tzpoints = [];
    else
        Xdata{i} = Xtmp;
        score{i} = mdl(Xtmp')';
        [~, maxid] = max(score{i});
%     [Psort, isort] = sort(PDDD, 'Descend');
%     maxid = isort(1);
%     [~, maxid] = max(PDD);
        maxid = maxid-1;
        tzpoints(i, :) = cw{i}(maxid, :);
        qctz(i) = itipup(tzpoints(i, 2), tzpoints(i, 1));
    end
end

end
