function timeArray = updatetimeArray(clInfo)
iMat = 1:size(clInfo, 1);

tMax = max(clInfo(:, 10));
timeArray = zeros(tMax, 2);

for t = 1:tMax
    tIndices = iMat(clInfo(:, 10)==t);
    timeArray(t, 1) = min(tIndices);
    timeArray(t, 2) = max(tIndices);
end
end

