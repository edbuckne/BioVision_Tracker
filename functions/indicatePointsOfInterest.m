function indicatePointsOfInterest(spmVec, cm, saveName)

load('data_config');

if exist([saveName '.mat'])
    load(saveName);
else
    data = [];
end

for spm = spmVec
    disp(['SPM' num2str(spm, '%.2u')]);
    ind = tSpm(:, 1) == spm;
    tRange = tSpm(ind, 2:3);
    
    for t = tRange(1):tRange(2)
        point = indicatePointOnSPM(spm, t, cm);
        
        data = [data; spm, t, round(point)];
    end
    save(saveName, 'data');
end

save(saveName, 'data');
end

