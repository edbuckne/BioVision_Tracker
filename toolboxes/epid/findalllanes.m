function [lanes] = findalllanes(iup, immask, iphase, angl)
% finds all lanes in an upright image of an arabidopsis root.

S = size(iup);
iupfilt = imgaussfilt(iup, 2); % Gather the second derivative in both directions
[igradmag1, igraddir1] = imgradient(iupfilt);
igradx1 = igradmag1 .* cosd(igraddir1);
igrady1 = igradmag1 .* sind(igraddir1);
clear('igradmag1'); clear('igraddir1');
[igradxmag2, igradxdir2] = imgradient(igradx1);
[igradymag2, igradydir2] = imgradient(igrady1);
igradx2 = igradxmag2 .* cosd(igradxdir2);
igrady2 = igradymag2 .* sind(igradydir2);

iphasex = imrotate(iphase, angl) .* double(igradx2<0.1) .* imrotate(immask, angl); % Only consider areas of local maxima
iphasey = imrotate(iphase, angl) .* double(igrady2<0.1) .* imrotate(immask, angl);

pp = [];  % Collect points of local maximum along the y direction of the image
filtord = 10;
filtb = ones(1, filtord)./filtord;
colidx = 1:S(2);
for row = 1:S(1)
    data = filtfilt(filtb, 1, iphasex(row, :));
    dmax = islocalmax(data);
    pp = [pp; colidx(dmax)', ones(sum(double(dmax)), 1).*row];
end

pointsid = 1:size(pp, 1);  % Detect lanes based on the local maxima data
linematch = zeros(size(pp, 1), 2);
firstrow = pp(1, 2);
laneid = -1;
originalbuff = 20;
thdist = 4;
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
    if sum(lane1) >= 50
        count = count + 1;
        lanes{count} = pp(lane1, :);
    end
end

for k = 1:length(lanes) % Go through each lane
    if isempty(lanes{k}) % Cutoff the lanes cell when there are no more lanes
        lanes = lanes(1:(k-1));
        break;
    end
end
end

