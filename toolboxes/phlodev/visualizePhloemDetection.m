spm = 1;
t = 1;

[i, i2] = phloemDetectedIndices(spm, t, 'trainedNN.mat');
f = plotPointsOnSpecimen(spm, t, i, '*g');
plotPointsOnSpecimen(spm, t, i2, '+r', f);