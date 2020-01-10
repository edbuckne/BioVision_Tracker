function im3d = showTrack(spm, varargin)
% showTrack.m - Takes in the specimen number and shows the tracking of COG
% points throughout the time course. The first varargin argument can be a
% vector that contains the time stamps to evaluate.

load('data_config');
spmName = ['SPM' num2str(spm, '%.2u')]; % Directory holding the specimen data

spmID = find(tSpm(:, 1)==spm);

load([spmName '/cell_location_information.mat']); % COG information
load([spmName '/PC_Relationships.mat']); % Tracking information

randColor = rand(size(clInfo, 1), 3).*0.8+0.2; % Random color generator (light colors)

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
    if exist('f', 'var')
        close(f);
    end
    f = figure;
    imshow(spreadPixelRange(max(I, [], 3)));
    hold on
    
    for i = timeArray(t, 1):timeArray(t, 2)
        if i==0 || isnan(i)
            continue;
        end
        if PC(i, 2)==0
            scatter(clInfo(i, 1), clInfo(i, 2), '.', 'MarkerEdgeColor', randColor(i, :));
        else
            j = i;
            while ~(PC(j, 2)==0) % Find initial instance
                j = PC(j, 2);
            end
            C = randColor(j, :); % Color for this instance
            while (PC(j, 1)<=i)&&~(PC(j, 1)==0)
                line([clInfo(j, 1), clInfo(PC(j, 1), 1)], [clInfo(j, 2), clInfo(PC(j, 1), 2)], 'Color', C);
                j = PC(j, 1);
            end
        end
    end
    text(50, 50, ['t=' num2str(t)], 'Color', 'w');
    saveas(f, 'tmp.jpg');
    Iin = im2double(imread('tmp.jpg'));
    delete('tmp.jpg');
    if t==tRange(1)
        im3d = zeros(size(Iin, 1), size(Iin, 2), 3, length(tRange));
    end
    im3d(:, :, :, t) = Iin;
    
    pause(2)
end

createGif(im3d, ['Track' num2str(spm, '%.2u')], inf, 0.5, 3);

end

