function D = closestNeighborDistance(spm, id)
load(['SPM' num2str(spm, '%.2u') '/cell_location_information.mat'])
load('data_config.mat')

indMat = 1:size(clInfo, 1);  % This matrix allows us to manipulate indices callings
siftOut = ~(indMat==id);  % Identify the indices that is not the IOI

xyIOI = clInfo(id, 1:2);  % Split the data into IOI and not IOI
xyOther = clInfo(siftOut, 1:2);

M = distmatrix2d(xyIOI.*xPix, xyOther.*xPix);  % Find the distance of all points to this one point in microns
D = min(M(:));  % Find the minimum distance and return that value

end

