function [outputArg1,outputArg2] = showTrack(spm, varargin)
% showTrack.m - Takes in the specimen number and shows the tracking of COG
% points throughout the time course. The first varargin argument can be a
% vector that contains the time stamps to evaluate.

load('data_config');
spmName = ['SPM' num2str(spm, '%.2u')]; % Directory holding the specimen data
cd(spmName);
spmID = find(tSpm(:, 1)==spm);

load('cell_location_information.mat'); % COG information
load('PC_Relationships.mat'); % Tracking information

if length(varargin)>=1 % varargin{1} is time vector
    tRange = varargin{1};
else
    tRange = tSpm(spmID, 2):tSpm(spmID, 3);
end

for t = tRange
    if isnan(timeArray(t, 1)) % If it has been rejected, ignore it
        continue;
    end
    I = microImInputRaw(spm, t, 1, 1); % Load and print maximum projection
    hold off
    imshow(spreadPixelRange(max(I, [], 3)));
    hold on
    
    for i = timeArray(t, 1):timeArray(t, 2)
        if i==0 || isnan(i)
            continue;
        end
        if PC(i, 2)==0
            scatter(clInfo(i, 1), clInfo(i, 2), 'r');
        else
            scatter(clInfo(i, 1), clInfo(i, 2), 'g');
            line([clInfo(PC(i, 2), 1), clInfo(i, 1)], [clInfo(PC(i, 2), 2), clInfo(i, 2)], 'Color', 'b');
        end
    end
    text(50, 50, ['t=' num2str(t)], 'Color', 'w');
    
    pause(2)
end
cd ..

end

