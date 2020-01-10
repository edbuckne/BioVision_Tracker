function [d, f] = showPhloemLevels(spm, t, graph, fin)
I = microImInputRaw(spm, t, 1, 1);
textSize = 6;
if graph
    if exist('fin', 'var')
        f = fin;
        hold on
    else
        f = figure;
        imshow(spreadPixelRange(max(I, [], 3)));
        hold on
    end
else
    f = NaN;
end


clInfo = loadclInfo(spm);
indMat = getIndMat(spm, t);
try
    load(['SPM' num2str(spm, '%.2u') '/elongationIndex.mat']);
catch
    loadfail = true;
end
d = zeros(length(indMat), 2);
S = size(I);

disp('Calculating Elongation Index')
for id = indMat

d(id, 1) = id;
if exist('ei', 'var')
    d(id, 2) = ei(id);
else
d(id, 2) = elongationIndex(spm, id, I);
end

if graph
    text(clInfo(id, 1), clInfo(id, 2), ['<' num2str(d(id, 2)) '>'], 'Color', 'g', 'Fontsize', textSize);
    hold on
end
end
end

