function showPhloemDetection(spm, t, modelName)
% visualizePhloemDetection takes in the specimen number (spm), time stamp
% (t) and the name of the saved model (modelName). It then collects data
% about each detected point and determines if it is a phloem point
% depending on the trained model which is a classifying neural network. It
% will then print an image and indicate the positive phloem (green stars)
% and the negative phloem (red cross)
[i, i2] = phloemDetectedIndices(spm, t, modelName);
f = plotPointsOnSpecimen(spm, t, i, '*g');
plotPointsOnSpecimen(spm, t, i2, '+r', f);
end

