function [iout, inotOut] = phloemDetectedIndices(spm, t, loadName)
load(['SPM' num2str(spm, '%.2u') '/cell_location_information.mat']);
load(['SPM' num2str(spm, '%.2u') '/cylCoord.mat']);
load(['SPM' num2str(spm, '%.2u') '/shape_info.mat']);
load(loadName);

indMat = 1:size(clInfo, 1);
tIndex = indMat(clInfo(:, 10)==t);

X = zeros(length(tIndex), 6);
ef = getExtraFeatures(spm, tIndex);

% X = [shapeInfo(tIndex, 4), cylCoord(tIndex, 1:2), ef]';
X = collectDataset('none', 'none', features, true, spm, t);
% X2 = NN.trans11(X);
% Y = NN.predict(X2);
Y = net(X');

iout = tIndex(Y(1, :)>Y(2, :));
inotOut = tIndex(Y(1, :)<=Y(2, :));
end

