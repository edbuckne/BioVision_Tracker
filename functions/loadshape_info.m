function [si, st] = loadshape_info(spm)
load(['SPM' num2str(spm, '%.2u') '/shape_info.mat']);
si = shapeInfo;
st = statsTot;
end

