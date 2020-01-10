function cb = cellsBelowNumber(spm, id)
N = 0;  % Number of regions closer to the root than this one

load(['SPM' num2str(spm, '%.2u') '/cylCoord.mat'])

tmp = cylCoord(cylCoord(:, 1)<cylCoord(id, 1), 1);
cb = length(tmp);
end

