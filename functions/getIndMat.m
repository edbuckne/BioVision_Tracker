function indMat = getIndMat(spm, t)
clInfo = loadclInfo(spm);
i = 1:size(clInfo, 1);
indMat = i(clInfo(:, 10)==t);
end

