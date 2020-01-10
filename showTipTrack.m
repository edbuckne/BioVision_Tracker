function showTipTrack( spm, printCM, varargin )
% showTipTrack.m - This function takes in the specimen to track the tip of
% and prints out a 3D .tif image showing its indication of the tip of the
% root.
% Inputs:
%   spm - (int) Specimen number to be tracked.
%   varargin{1} - (int vector) List of time stamps to evaluate this. If
%       left blank, all time stamps will be evaluated.

load('data_config.mat')
spmId = find(tSpm(:, 1)==spm); % Find the specimen index
R = 100;
nomPoint = [960, 1700];

if ~isempty(varargin) % Store the time range into variable
    tRange = varargin{1}; 
else
    tRange = tSpm(spmId, 2):tSpm(spmId, 3); % If the time range isn't specified, use all time stamps
end

I = microImInputRaw(spm, tRange(1), 2, 1); % Load the first image to get dimensions
if printCM==1
    I = microImInputRaw(spm, 1, 1, 1);
    [~, pmin, pmax] = spreadPixelRange(I);
end
Sim = size(I);
Itip = zeros(Sim(1), Sim(2)); % Itip holds the current image with tip identified

Ixy = zeros(Sim(1), Sim(2), 2); % Ixy holds the x and y positions of each pixel
for row = 1:Sim(1)
    for col = 1:Sim(2)
        Ixy(row, col, 1) = col; % First z slice holds x positions
        Ixy(row, col, 2) = row; % Second z slice holds y positions
    end
end

if exist(['SPM' num2str(spm, '%.2u') '/tipTrack.mat'])
    load(['SPM' num2str(spm, '%.2u') '/tipTrack'])
else
    tipLoc = [];
end
delShift = [];

if exist(['tiptrack_spm' num2str(spm, '%.2u') '_CM' num2str(printCM) '.tif']) % If there exists an already tracked tip, delete it
    delete(['tiptrack_spm' num2str(spm, '%.2u') '_CM' num2str(printCM) '.tif']);
end

for t = tRange
    if exist(['SPM' num2str(spm, '%.2u') '/tipTrack.mat']) % If tipTrack file already exists, just use those x and y values
        x = tipLoc(t, 1);
        y = tipLoc(t, 2);
        Imax = max(I, [], 3);
    else
        if ~(t==tRange(1)) % If it is the first time stamp, we have already loaded the image into the variable I
            I = microImInputRaw(spm, t, 2, 1);
        end
        Imax = max(I, [], 3);
        [x, y] = findTip('av.mat', I);
        tipLoc = [tipLoc; x, y];
    end
    delShift = [delShift; nomPoint-[x, y]];   
    
    xMinus = Ixy(:, :, 1) - x;
    yMinus = Ixy(:, :, 2) - y;
%     Imax(logical((sqrt(xMinus.^2+yMinus.^2)>R).*(sqrt(xMinus.^2+yMinus.^2)<(R+5)))) = 1;
    if printCM==1
        I = microImInputRaw(spm, t, 1, 1);
        Imax = max(I, [], 3);
        imwrite(imtranslate(((Imax-pmin)./(pmax-pmin)), delShift(end, :)), ['tiptrack_spm' num2str(spm, '%.2u') '_CM' num2str(printCM) '.tif'], 'writemode', 'append');
    else
        I = microImInputRaw(spm, t, 2, 1);
        Imax = max(I, [], 3);
        imwrite(imtranslate(Imax, delShift(end, :)), ['tiptrack_spm' num2str(spm, '%.2u') '_CM' num2str(printCM) '.tif'], 'writemode', 'append');
    end
    
end
    save(['SPM' num2str(spm, '%.2u') '/tipTrack'], 'delShift', 'tipLoc');
end

