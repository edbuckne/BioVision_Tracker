function BVTregister( varargin )
% BVTregister.m
%
% A highest level BVT function, takes an input from the user about how far
% a shift is to be expected and performs a point matching image
% registration operation on the COG points calculated in BVTseg3d.m
% Input:
%   varargin{1} (int) - specimen number to register points
%   varargin{2} (1x3 int) - x, y, and z maximum shift values
%   varargin{3} (log) - true means rejection of regions outside of
%       indicated mask of root. False means otherwise.
%   varargin{4} (vector int) - time stamps to be evaluated.
% Output:
%   None

load data_config

if(size(varargin,2)==0)
    spm = input('Which specimen do you want to track? ');
else
    spm = varargin{1};
end
sInd = find(tSpm(:, 1)==spm);
tmStart = tSpm(sInd, 2); tmEnd = tSpm(sInd, 3);
cd(['SPM' num2str(spm,'%.2u')]);

maxDis = zeros(1,3);
if(size(varargin,2)<2)
    maxDis(1) = input('What is the max shift distance in the x direction? ');
    maxDis(2) = input('What is the max shift distance in the y direction? ');
    maxDis(3) = input('What is the max shift distance in the z direction? ');
else
    maxDis(1) = varargin{2}(1);
    maxDis(2) = varargin{2}(2);
    maxDis(3) = varargin{2}(3);
end
if length(varargin)>=3
    reject = varargin{3};
else
    reject = false;
end
if(size(varargin,2)>=4)
    tRange = varargin{4};
else
    tRange = tmStart:tmEnd;
end
if exist('delta_set.mat')
    load('delta_set.mat');
else
    timeDiff = length(tRange)-1; %How many time points are we looking at?
    delSet = zeros(timeDiff,5); %As of right now only looking at the translation
end

load zStacks
%This section takes the points and executes the point matching image
%registration algorithm
CLt0start = 1; %Indices for cell location and contour points
CLtoend = 0;
CPtostart = 1;
CPtoend = 0;
r = 5;

load('cell_location_information.mat'); %load the cell location information


sCL = size(clInfo);

if reject
    disp('Rejecting Regions Outside Root')
    rejectCount = 0;
    for t = tRange
        Imask = im2double(imread(['MIDLINE/mask' num2str(t, '%.4u') '.tif'])); % Take in the mask image
        if sum(Imask(:))==0 % Don't bother if the mask image is blank
            continue;
        end
        for i = timeArray(t, 1):timeArray(t, 2)
            if i==0 % In case of a blank time stamp
                break;
            end
            if clInfo(i, 1)==0 % In case this has already been run
                continue;
            end
            if Imask(clInfo(i, 2), clInfo(i, 1))==0
                clInfo(i, :) = zeros(1, size(clInfo, 2)); % Put zeros where there is a rejected region
                rejectCount = rejectCount+1;
            end
        end
    end
    disp([num2str(rejectCount) ' COG''s were rejected']);
    save('cell_location_information', 'clInfo', 'timeArray');
end

%Find the starting time stamps points
i=CLt0start;
while(clInfo(i,10)==tmStart)
    i=i+1;
end
CLt0end = i-1;

tRange = tRange(2:end);
for t=tRange
    disp(['Registering point matching for time ' num2str(t-1) ' to ' num2str(t)]);
    if((timeArray(t-1, 1)==0)||timeArray(t, 1)==0)
        continue;
    end
%     CLt1start = i; %Algorithm on pg. 69 of personal notebook on finding time stamp points
%     while(clInfo(i,10)==t && i<sCL(1))
%         i=i+1;
%     end
%     CLt1end = i-1;
    
%     CLt0 = clInfo(CLt0start:CLt0end,1:3)'; %All of the t0 COG points
%     CLt0 = CLt0(:, CLt0(1, :)>0); % Don't consider rejected COG's
%     CLt1 = clInfo(CLt1start:CLt1end,1:3)'; %All of the t1 COG points
%     CLt1 = CLt1(:, CLt1(1, :)>0);
    
    CLt0 = clInfo(timeArray(t-1, 1):timeArray(t-1, 2), 1:3)';
    CLt0 = CLt0(:, CLt0(1, :)>0); % Don't consider rejected COG's
    CLt1 = clInfo(timeArray(t, 1):timeArray(t, 2), 1:3)';
    CLt1 = CLt1(:, CLt1(1, :)>0); % Don't consider rejected COG's
    
    delSet(t-1,1:3) = regPM3D(CLt0,CLt1,r,maxDis,xyratz); %3D point matching image registration
    
%     CLt0start = CLt1start; %Next time stamp
%     CLt0end = CLt1end;
    save('delta_set','delSet');
end

save('delta_set','delSet');
cd ..

end

