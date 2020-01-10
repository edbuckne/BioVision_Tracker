function out = loadcylCoord(spm)
load(['SPM' num2str(spm, '%.2u') '/cylCoord.mat']);
out = cylCoord;
end

