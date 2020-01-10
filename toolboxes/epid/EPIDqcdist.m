function EPIDqcdist(SPM, varargin)
% EPIDdetect.m is a function at the highest level of the epid toolbox. This
% function takes in the specimen and finds the distance of each cell (both
% epidermal and non-epidermal cells) from the location from tipTrack.mat.
% If tipTrack.mat does not exist, this function uses the bottom of the
% midline to be where the measurement is taken from.
% Functions that must have already been ran
%   BVTconfig
%   BVTreconstruct or BVTreconstructunet
%   BVTreconstruct or correctTipLoc
%   EPIDdetect

defaultTimeSetting = 'all';
defaultTimeRange = 1;

expectedTimeSetting = {'all', 'spec'};

p = inputParser();
addRequired(p, 'SPM');  % The number of the specimen
addParameter(p, 'TimeRange', defaultTimeRange);  % Only read if the 'TimeSetting' is set to 'spec'. Tells which time stamps to evaluate
addParameter(p, 'TimeSetting', defaultTimeSetting, ...
    @(x) any(validatestring(x, expectedTimeSetting)));  % 'all' means all time stamps will be evaluated and 'spec' means a range has been specified
parse(p, SPM, varargin{:});

load('data_config.mat');

spmdir = ['SPM' num2str(SPM, '%.2u')];  % Specimen directory

sInd = find(tSpm(:, 1)==SPM);  % Find the index of this specimen in the tSpm matrix
if strcmp(p.Results.TimeSetting, 'all')  % Indicate whether the user specifies a time range
    tRange = tSpm(sInd, 2):tSpm(sInd, 3);
else
    tRange = p.Results.TimeRange;
end

for i = 1:length(tRange)
    t = tRange(i);  % Get the time stamp
    
    epidfile = [spmdir '/EPID/ep' num2str(t, '%.4u')];  % Load necessary files for this time stamp
    load(epidfile, 'P');
    mlfile = [spmdir '/MIDLINE/ml' num2str(t, '%.4u')];
    load(mlfile, 'S');
    
    if ~exist([spmdir '/tipTrack.mat'], 'file')  % Get the location to measure from
        yS = length(S);
    else
        load([spmdir '/tipTrack.mat'], 'tipLoc');
        yS = tipLoc;
    end
    
    imtip = createtipmap(SPM, t, S, yS(2));
    
    QC = zeros(size(P, 1), 1);
    for j = 1:size(P, 1)  % Go to each cell and measure the qc distance
        QC(j) = imtip(P(j, 2), P(j, 1));
    end
    
    save([spmdir '/EPID/qc' num2str(t, '%.4u')], 'QC');
end
end

