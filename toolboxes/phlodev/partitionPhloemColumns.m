function [idx, partN] = partitionPhloemColumns(spm, t, TH)
cylCoord = loadcylCoord(spm);  % Load cylindrical coordinates for this specimen
indMat = getIndMat(spm, t);  % Get the indices for this time stamp
X = [cylCoord(indMat, 2), cylCoord(indMat, 3)];  % Collect center distance and angle from x axis

diffCol = false;  % Tells if a region has been found outside of the TH
for i = 2:size(X, 1)
    if (abs(X(1, 1)-X(i, 1))>TH(1))||(abs(X(1, 2)-X(i, 2))>TH(2))
        diffCol = true;
        break;
    end
end

if diffCol
    idx = kmeans(X, 2);  % Calculate the kmean partition
    partN = 2;
else
    idx = ones(size(X, 1), 1);
    partN = 1;
end
    
end

