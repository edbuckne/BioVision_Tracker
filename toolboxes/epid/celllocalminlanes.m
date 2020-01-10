function [lanedata] = celllocalminlanes(igradx2, igrady2, iphase, immask, angl, epidLanes, itipup)
% celllocalminlanes(igradx2, igraady2, iphase, immask, angl, epidLanes) -
% detects the indices in the lanes in which a cell wall is found.
load('./data_config', 'xPix');

iphasex = imrotate(iphase, angl) .* double(igradx2<0.1) .* imrotate(immask, angl); % Only consider areas of local maxima
iphasey = imrotate(iphase, angl) .* double(igrady2<0.1) .* imrotate(immask, angl);

lanes = epidLanes;
lanedata = cell(length(lanes), 1);
for k = 1:length(lanes) % Go through each lane
    thislanedata = zeros(size(lanes{k}, 1), 3); % Holds the qc data and image energy data
    for i = 1:length(lanes{k}) % Go through each point in this lane
        point = lanes{k}(i, :);
        energy = igrady2(point(2), point(1));
        qc = itipup(point(2), point(1));
        thislanedata(i, :) = [point(2), energy, qc];
    end
    energymean = mean(thislanedata(:, 2)); % Normalize the signal
    energystdev = sqrt(var(thislanedata(:, 2)));
    normstdev = zeros(size(thislanedata, 1), 1);
    for i = 6:size(thislanedata, 1)
        normstdev(i) = sqrt(var(thislanedata((i-5):i, 2)))./energystdev;
    end
    normsig = (thislanedata(:, 2)-energymean)./energystdev;
    peaksig = normsig .* normstdev;
    
    cellwallidx = double(peaksig>0.4) .* double(islocalmax(peaksig)) .* double(thislanedata(:, 3)>xPix);
    
    lanedata{k, 1} = cellwallidx;
end

end

