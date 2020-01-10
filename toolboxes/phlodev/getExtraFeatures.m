function F = getExtraFeatures(spm, index)
cn = zeros(length(index), 1);
sf = zeros(length(index), 1);
cb = zeros(length(index), 1);
% var = zeros(length(index), 3);

for i = 1:length(index)
    cn(i) = closestNeighborDistance(spm, index(i));
    sf(i) = sameFileNumber(spm, index(i), [5, 0.1]);
    cb(i) = cellsBelowNumber(spm, index(i));
end

F = [cn, sf, cb];
end

