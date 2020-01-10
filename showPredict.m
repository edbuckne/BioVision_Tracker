function showPredict(spm, t, loadName)
load(loadName);

Imax = showMaxProj(spm, t, 1, true, false);
figure
imshow(Imax)
hold on
[clInfo, timeArray] = loadclInfo(spm);

[X, ~] = collectDataset('none', 'none', features, true, spm, t);
output = net(X');
output = output(1, :)>output(2, :);

ta = timeArray(t, 1):timeArray(t, 2);
for i = 1:length(ta)
    if output(i)
        scatter(clInfo(ta(i), 1), clInfo(ta(i), 2), '*g');
        hold on
    else
        scatter(clInfo(ta(i), 1), clInfo(ta(i), 2), '*r');
        hold on
    end
end
end

