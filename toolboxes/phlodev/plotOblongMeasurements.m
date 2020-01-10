spmN = 13;
figure
for spm = 1:spmN
    D = showPhloemLevels(spm, 1, false);
    dLength = size(D, 1);
    
    cylCoord = loadcylCoord(spm);
    scatter(cylCoord(D(:, 1), 1), log(D(:, 2)));
    hold on
end