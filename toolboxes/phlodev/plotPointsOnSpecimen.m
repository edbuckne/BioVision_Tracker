function fig = plotPointsOnSpecimen(spm, t, i, style, f)
load(['SPM' num2str(spm, '%.2u') '/cell_location_information.mat']);

I = microImInputRaw(spm, t, 1, 1);
Imax = max(spreadPixelRange(I), [], 3);


if ~exist('f', 'var')
    fig = figure;
    imshow(Imax);
else
    fig = f;
    figure(f);
end
hold on
scatter(clInfo(i, 1), clInfo(i, 2), style)
end

