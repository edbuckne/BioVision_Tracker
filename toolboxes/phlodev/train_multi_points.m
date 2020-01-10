load('../phloemTrainingData.mat')

spmN = length(data);
multiIndexing = [];
multiData = [];

for spm = 1:spmN
    if length(data(spm).phloemmulti)==0  % If the specimen does not have multi-indication, don't collect data
        continue;
    else
        load(['SPM' num2str(spm, '%.2u') '/cell_location_information.mat'])
        load(['SPM' num2str(spm, '%.2u') '/cylCoord.mat'])
        load(['SPM' num2str(spm, '%.2u') '/shape_info.mat'])
        
        for i = 1:length(data(spm).phloemmulti)
            multiIndexing = [multiIndexing; spm, data(spm).phloemmulti(i)];
        end
    end
    multiData = [multiData; clInfo(data(spm).phloemmulti, :), ...
                 shapeInfo(data(spm).phloemmulti, :), ...
                 cylCoord(data(spm).phloemmulti, :), ...
                 getExtraFeatures(spm, data(spm).phloemmulti)];
end