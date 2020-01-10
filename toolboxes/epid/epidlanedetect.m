function [lanes, angl] = epidlanedetect(Iin, Iath, varargin)
% epidlanedetect.m takes in an image of an arabidopsis root (Iin) and
% detects where the lanes are located (eg. the different cell files)

defaultSmooth = 1;  % Smoothing coefficient for image filter
defaultFiltord = 10;  % Filter order for 1D filter
defaultOriginalbuff = 20;  % Window size of the points to look at for connecting lanes
defaultThdist = 4;  % The threshold distance of pixels to determine to connect lanes
defaultMinlanelength = 50;  % The minimum amount of points that can belong in a lane
defaultNscale = 4;  % Number of scales to use in local symmetry
defaultNorient = 6;  % Number of orientation to use in local symmetry
defaultForeground = 'dark';  % Whether it is brightfield or darkfield

expectedForeground = {'dark', 'bright'};

p = inputParser;
addRequired(p, 'Iin');
addParameter(p, 'SmoothParameter', defaultSmooth);
addParameter(p, 'FilterOrder', defaultFiltord);
addParameter(p, 'OriginalBuffer', defaultOriginalbuff);
addParameter(p, 'ThresholdDistance', defaultThdist);
addParameter(p, 'MinimumLaneLength', defaultMinlanelength);
addParameter(p, 'NumberOfScales', defaultNscale);
addParameter(p, 'NumberOfOrientations', defaultNorient);
addParameter(p, 'Foreground', defaultForeground, ...
    @(x) any(validatestring(x, expectedForeground)));
parse(p, Iin, varargin{:});

if strcmp(p.Results.Foreground, 'dark')  % Make it a brightfield image
    Iin = 1 - Iin;
end

imzfilt = imgaussfilt(Iin, p.Results.SmoothParameter);  % Filter the image

phaseSym = phasesym(imzfilt, p.Results.NumberOfScales, ...
    p.Results.NumberOfOrientations);  % Local symmetry operation

immask = predictrootmaskunet(Iin);  % Predicts a mask for the root

phasesymth = Iath .* phaseSym .* immask;  % Mask the phase symmetry image

immaskfilt = imgaussfilt(double(immask), 50);  % Solve for the orientation of the root
O = -90:5:90;
C = zeros(length(O), 1);
Vy = zeros(length(O), 1);
for o = 1:length(O)
    deg = O(o);
    C(o) = calcCxy(imrotate(immaskfilt, deg));  % The covariance of the upright root is 0
    [~, Vy(o)] = calcVxVy(imrotate(immaskfilt, deg));  % It is upright when Vy is at a maximum
end
fromzero = abs(C);
locminind = islocalmin(fromzero);
Vyatlocmin = Vy .* double(locminind);
[~, angind] = max(Vyatlocmin);
angl = O(angind);

phasesymth = imrotate(phasesymth, angl);  % Rotate the images accordingly
S = size(phasesymth);

pp = [];  % Collect points of local maximum along the y direction of the image
filtord = p.Results.FilterOrder;
filtb = ones(1, filtord)./filtord;
colidx = 1:S(2);
for row = 1:S(1)
    data = filtfilt(filtb, 1, phasesymth(row, :));
    dmax = islocalmax(data);
    pp = [pp; colidx(dmax)', ones(sum(double(dmax)), 1).*row];
end

pointsid = 1:size(pp, 1);  % Detect lanes based on the local maxima data
linematch = zeros(size(pp, 1), 2);
firstrow = pp(1, 2);
laneid = -1;
originalbuff = p.Results.OriginalBuffer;
thdist = p.Results.ThresholdDistance;
for i = 1:size(pp, 1)
    thisrow = pp(i, 2);  % Collect the value for the row of this point
    if thisrow == firstrow  % If this is the first lane encountered, then it has no matching pair
        linematch(i, 2) = laneid;  % Give this point the lane id
        laneid = laneid - 1;  % Decrement the lane id
        continue;
    end
    prerowlist = pp(logical((pp(:, 2)<(thisrow)).*(pp(:, 2)>(thisrow - originalbuff))), 1);  % List of points in the previous row
    prerowid = pointsid(logical((pp(:, 2)<(thisrow)).*(pp(:, 2)>(thisrow - originalbuff))));  % List the ids for the points of the previous row
    dist1d = abs(prerowlist - pp(i, 1));  % Collect the distances this point is from all others in the previous row
    [mindist, minidx] = min(dist1d);
    if mindist <= thdist
        idold = prerowid(minidx);  % Make note of the id this point is closest to
        linematch(i, 1) = idold;
        linematch(i, 2) = linematch(idold, 2);  % Make note of which lane id this is
    else
        linematch(i, 2) = laneid;  % Create a new lane id
        laneid = laneid - 1;
    end
end

lanes = cell(-min(linematch(:, 2)), 1);  % Finalize the lanes into a cell variable
count = 0;
for laneidinc = -1:-1:min(linematch(:, 2))
    lane1 = linematch(:, 2) == laneidinc;
    if sum(lane1) >= p.Results.MinimumLaneLength
        count = count + 1;
        lanes{count} = pp(lane1, :);
    end
end
end

