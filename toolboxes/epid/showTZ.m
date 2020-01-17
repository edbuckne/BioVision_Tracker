function [f] = showTZ(spm, t, varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
defaultScoreOption = 'None';

expectedScoreOption = {'None', 'Norm'};

p = inputParser();
addParameter(p, 'ScoreOption', defaultScoreOption, ...
    @(x) any(validatestring(x, expectedScoreOption))); 

parse(p, varargin{:});

spmdir = ['SPM' num2str(spm, '%.2u')]; % Get paths to files
tstr = num2str(t, '%.4u');
lanepath = [spmdir '/EPID/lanes' tstr '.mat'];
cellpath = [spmdir '/EPID/cells' tstr '.mat'];
tranpath = [spmdir '/EPID/tz' tstr '.mat'];

if ~exist(lanepath, 'file')
    error('Must have ran EPIDLane first');
elseif ~exist(cellpath, 'file')
    error('Must have ran EPIDcell first');
elseif ~exist(tranpath, 'file')
    error('Must have ran EPIDtz first');
end

load(lanepath); % Load the data
load(cellpath);
load(tranpath);

f = figure;
imshow(imrotate(imz, angl));
hold on
for i = 1:length(score)
    thisscore = score{i}; % Get the values of the scores here
    thispoints = cw{i}; % Get the points for the cell walls on the image
    
    nanpoints = isnan(thisscore); % Find the nan scores
    
    thisscore = thisscore(~nanpoints);
    thispoints = thispoints(~nanpoints, :);
    
    minscore = min(thisscore); % Normalize to the smallest value
    thisscore = thisscore-minscore;
    
    for j = 1:length(thisscore)
        scatter(thispoints(j, 1), thispoints(j, 2), '.r');
        if strcmp(p.Results.ScoreOption, 'Norm')
            text(thispoints(j, 1), thispoints(j, 2), num2str(thisscore(j)));
        end
    end
    scatter(tzpoints(i, 1), tzpoints(i, 2), 'ob');
end
end

