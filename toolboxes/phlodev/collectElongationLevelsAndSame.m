saveName = 'elongationVsRootTipDist';

load data_config

data = [];

for spmi = 1:size(tSpm, 1)
    spm = tSpm(spmi, 1);
    cylCoord = loadcylCoord(spm);
    
    D = showPhloemDevelopment(spm, 1, false);
    data = [data; ones(size(D, 1), 1).*spm, D, cylCoord(:, 1)];
end