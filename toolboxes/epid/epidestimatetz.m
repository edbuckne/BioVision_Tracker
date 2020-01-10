function [Xdata, score] = epidestimatetz(spm, t, varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
defaultTZModel = 'tzMdl';

p = inputParser();
addParameter(p, 'TZModel', defaultTZModel); % The model used for predicting the cell at the TZ/EZ boundary

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
Xdata = cell(NepidLanes, 1); % Holds the features for each point
score = cell(NepidLanes, 1); % Holds the scores from the model to predict the TZ
for i = 1:NepidLanes
    cwPoints = epidLanes{i}(cwidx{i}==1, :); % Get the points of the cell walls in the epidermal file
    PlaneMu = cwPoints.*xPix; % Coordinates in microns
    Xtmp = zeros(size(PlaneMu, 1), features); % Holds the features
    [S, si] = sort(PlaneMu(:, 2), 'Descend'); % Sort the points by the y direction (largest to smallest)
    PlaneMu = [PlaneMu(si, 1), S];
    
    PlaneDiff = [0; abs(diff(PlaneMu(:, 2)))]; % Get the derivative and filter
    b = ones(1, 5)./5;
    PD = filtfilt(b, 1, PlaneDiff);
    PDD = [0; diff(PD)];
    cumData = zeros(length(PD), 2);
    for j = 1:size(cwPoints, 1)
        cumData(j, 1) = mean(PD(1:j));
        cumData(j, 2) = sqrt(var(PD(1:j)));
        
        Xtmp(j, 1) = PD(j); % First derivative
        Xtmp(j, 2) = PDD(j); % Second derivative
        Xtmp(j, 3) = (PD(j)-cumData(j, 1))./cumData(j, 2); % Normalized to all cells before
    end
    Xdata{i} = Xtmp;
    score{i} = mdl(Xtmp')';
end

end

