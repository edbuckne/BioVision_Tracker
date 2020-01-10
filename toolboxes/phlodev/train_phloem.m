load('../phloemTrainingData.mat')

spmN = length(data);
phloemIndexing = [];
phloemData = [];
notPhloemData = [];

for spm = 1:spmN
        load(['SPM' num2str(spm, '%.2u') '/cell_location_information.mat'])
        load(['SPM' num2str(spm, '%.2u') '/cylCoord.mat'])
        load(['SPM' num2str(spm, '%.2u') '/shape_info.mat'])
        
        indMat = 1:size(clInfo, 1);
        siftOut = ones(length(indMat), 1);
        siftOut(data(spm).phloemall) = 0;
        notPhloemIndexing = indMat(logical(siftOut))';
        
        for i = 1:length(data(spm).phloemall)
            phloemIndexing = [phloemIndexing; spm, data(spm).phloemall(i)];
        end
    phloemData = [phloemData; ones(length(data(spm).phloemall), 1).*spm, clInfo(data(spm).phloemall, :), ...
                 shapeInfo(data(spm).phloemall, :), ...
                 cylCoord(data(spm).phloemall, :), ...
                 getExtraFeatures(spm, data(spm).phloemall)];
    notPhloemData = [notPhloemData; ones(size(notPhloemIndexing, 1), 1).*spm, clInfo(notPhloemIndexing, :), ...
                 shapeInfo(notPhloemIndexing, :), ...
                 cylCoord(notPhloemIndexing, :), ...
                 getExtraFeatures(spm, notPhloemIndexing)];
end