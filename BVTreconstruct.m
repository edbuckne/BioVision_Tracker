function BVTreconstruct(varargin)
% BVTreconstruct.m
%
% Highest level function on the BVT software pipeline. This function is
% responsible for indicating and storing the midline information in
% addition to storing a mask image of the specimen from the brightfield
% channel.

load('data_config.mat');
if(size(varargin,1)==0) % Get the specimen information
    SPM = input('Which specimen do you want to reconstruct its surface? ');
else
    SPM = varargin{1};
end
sInd = find(tSpm(:, 1)==SPM);
tmStart = tSpm(sInd, 2); tmEnd = tSpm(sInd, 3);
cd(['SPM' num2str(SPM, '%.2u')]); % Go to specimen directory 

if ~exist('MIDLINE') % If the MIDLINE directory doesn't exist, create it
    mkdir MIDLINE
end
if length(varargin)==2
    tRange = varargin{2};
else
    tRange = tmStart:tmEnd;
end 

f = waitbar(0, 'Reconstructing surface');
for t = tRange % Run this operation for each time stamp
    prog = (t-tmStart+1)/(tmEnd-tmStart+1);
    waitbar(prog, f, ['Reconstructing surface ' num2str(t) ' of ' num2str(tmEnd)]);
    
    I = microImInputRaw(SPM,t,2,1); % Load image from the data set
    mZ = round(size(I, 3)/2);
    [S, Imask] = ATmidline(I); % Create the mask image and calculate the midline
    save(['MIDLINE/ml' num2str(t, '%.4u') '.mat'], 'S', 'mZ');
    imwrite(Imask, ['MIDLINE/mask' num2str(t, '%.4u') '.tif']);
end

close(f)
cd ..
end

