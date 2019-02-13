function BVTmap( varargin )
% BVTmap.m
%
% A highest level BVT function, connects the information collected from
% BVTreconstruc and BVTseg3d and creates a data set where each element in
% the clInfo variable is given the 3 metrics distance from root tip,
% distance from root center, and angular position along the midline.

load data_config

if(size(varargin,2)==0) % Get the specimen number
    spm = input('Which specimen do you want to map? ');
else
    spm = varargin{1};
end

sInd = find(tSpm(:, 1)==spm);
tmStart = tSpm(sInd, 2); tmEnd = tSpm(sInd, 3);
cd(['SPM' num2str(spm,'%.2u')]);
load('cell_location_information.mat');
if exist('delta_set.mat')
load('delta_set')
else
    delSet = [];
end
if exist('tipTrack.mat')  % If tip showTipTrack.m has not been ran on this specimen, use gfp shift
    load('tipTrack')
    delShift02 = zeros(size(delShift, 1)-1, 2);
    for t = 1:size(delShift02, 1)
        delShift02(t, :) = delShift(t, :)-delShift(t+1, :);
    end
    delShift = delShift02;
else
    delShift = delSet;
end

cylCoord = zeros(size(clInfo, 1), 3); % Cylindrical coordinate metric array
Sold = [];

for t = tmStart:tmEnd % Go through each time stamp
%     t
    if(timeArray(t, 1)==0 || isnan(timeArray(t, 1))) % Don't do anything if it is an empty array
        continue;
    end
    if ~exist(['MIDLINE/ml' num2str(t, '%.4u') '.mat'])
        continue;
    else
        load(['MIDLINE/ml' num2str(t, '%.4u')]); % load the midline information
    end
    exitVar = 1;
    updatePsi = 0;
    emptyS = 0;
    
    if t==7
        a = 0;
    end
    if exist('tipTrack.mat')
        if tipLoc(t, 2)<length(S) %&& sqrt((tipLoc(t, 1)-S(end)).^2+(tipLoc(t, 2)-length(S)).^2)<100 % We only want to integrate to where the tip is
            yS = tipLoc(t, 2);
        else
            yS = length(S);
        end
    else
        yS = length(S);
    end
    
    while exitVar
        if t>1
            if isnan(timeArray(t-1, 1))
                break;
            end
        end
        for i = timeArray(t, 1):timeArray(t, 2) % Go through each element in this time array
            psi = 0;
            if clInfo(i, 1)==0
                continue;
            end
            y = clInfo(i, 2);
            
            for yy = yS-1:-1:y % Start at the tip and go upwards
                psi = psi+sqrt(1+(S(yy)-S(yy+1))^2);
            end
            
            if isempty(S)
                cylCoord(i, :) = [NaN, NaN, NaN];
                continue;
                emptyS = 1;
            else
                rho = sqrt(((clInfo(i, 1)-S(clInfo(i, 2))).*xPix)^2+(((clInfo(i, 3)-mZ)*zPix)^2)); % Radius from center
                theta = atan(((clInfo(i, 3)-mZ)*zPix)/((clInfo(i, 1)-S(clInfo(i, 2))).*xPix)); % Angle from x-axis
            end
            
            
            % Store values in cylCoord
            if updatePsi
                cylCoord(i, 1) = psi.*xPix;
                cylCoord(i, 2) = rho;
                cylCoord(i, 3) = theta;
            else
                cylCoord(i, 1) = psi.*xPix;
                cylCoord(i, 2) = rho;
                cylCoord(i, 3) = theta;
            end
            if emptyS
                cylCoord(i, 2) = rho;
                cylCoord(i, 3) = theta;
            end
        end
        if ~(t==tmStart)
            if((timeArray(t-1, 1)==0)&&(timeArray(t, 1)>0))
                Sold = S;
                break;
            elseif timeArray(t, 1)==0
                Sold = [];
                break;
            end
            PsiT1 = cylCoord(timeArray(t-1, 1):timeArray(t-1, 2), 1); % Get all distances from tip in this time stamp
            avgPsi1 = mean(PsiT1(PsiT1>0)); % Average distance from tip last time stamp above 0
            PsiT2 = cylCoord(timeArray(t, 1):timeArray(t, 2), 1);
            avgPsi2 = mean(PsiT2(PsiT2>0)); % Average distance from tip this time stamp
            %             if ((abs(avgPsi1-avgPsi2)>50)&&~(avgPsi1==0)) % Greater than 50 microns is huge, so we use old value of S but shifted
            %                 S = Sold+delSet(t-1, 1); % Shift by x
            %                 lenDiff = delSet(t-1, 2);
            %                 if lenDiff<0 % This means it is shorter
            %                     S = S(1:length(S)+lenDiff+1);
            %                 else % Longer
            %                     S = [ones(lenDiff, 1).*S(1); S];
            %                 end
            %                 updatePsi = 1;
            %             else
            %                 exitVar = 0;
            %             end
%             if ((abs(avgPsi1-avgPsi2)>50)&&~(avgPsi1==0)) % Greater than 50 microns is huge, so we use old value of S but shifted
%                 %                 yS = length(Sold)+delShift(t-1, 2);
%                 if exist('tipTrack.mat')
%                     yS = tipLoc(t, 2);
%                 else
%                     yS = length(Sold)+delShift(t-1, 2);
%                 end
%                 S = S(1:yS);
%                 updatePsi = 1;
%             else
%                 exitVar = 0;
%             end
            exitVar = 0;
        else
            exitVar = 0;
        end
        Sold = S;
    end
    
end

save('cylCoord', 'cylCoord')
cd ..
end

