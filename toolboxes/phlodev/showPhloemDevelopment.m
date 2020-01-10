function [D, b1, b2, f] = showPhloemDevelopment(spm, t, graph, f)
D = showPhloemLevels(spm, t, false);  % Calculate the elongation index of each phloem region
cylCoord = loadcylCoord(spm);  % Load the cylindrical coordinates of points in the root
clInfo = loadclInfo(spm);  % Load the cell location information
indMat = getIndMat(spm, t);  % Get the indices for this specimen and this time's regions
[label, partN] = partitionPhloemColumns(spm, t, [5, 1]);  % Partition the phloem files if necessary
ElongMax = 10;
ElongMin = 0;

if partN == 2  % If the phloem could be partitioned into two 
    i1 = D(label==1, 1);  % Get the partitioned indices
    i2 = D(label==2, 1);
    
    tipDis1 = [D(i1, 1), cylCoord(D(i1, 1), 1), log(D(i1, 2))];  % Create linear regression models for enucleation progress
    [B1, I1] = sort(tipDis1(:, 2), 1);
    x1 = tipDis1(I1, 2);
    X1 = [ones(length(x1),1) x1];
    b1 = X1\tipDis1(I1, 3);  % Linear regression operator
    tipDis2 = [D(i2, 1), cylCoord(D(i2, 1), 1), log(D(i2, 2))];
    [B2, I2] = sort(tipDis2(:, 2), 1);
    x2 = tipDis2(I2, 2);
    X2 = [ones(length(x2),1) x2];
    b2 = X2\tipDis2(I2, 3);  
else
    i1 = D(:, 1);
    tipDis1 = [D(i1, 1), cylCoord(D(i1, 1), 1), log(D(i1, 2))];  % Create linear regression models for enucleation progress
    [B1, I1] = sort(tipDis1(:, 2), 1);
    x1 = tipDis1(I1, 2);
    X1 = [ones(length(x1),1) x1];
    b1 = X1\tipDis1(I1, 3);  % Linear regression operator
    b2 = 0;
end

if graph
    I = microImInputRaw(spm, t, 1, 1);
    if ~exist('f', 'var')
        f = figure;
        imshow(spreadPixelRange(max(I, [], 3)));
        hold on
    else
        figure(f)
        hold on
    end
    for i = 1:length(label)
        if label(i)==1
            b = b1;  % Get the first linear regression model
            hold on
        else
            b = b2;  % Get the second linear regression model
            hold on
        end
        tipLoc = cylCoord(D(i, 1), 1);  % Get the tip distance of this region
        estElong = b(1)+tipLoc.*b(2);  % Get the estimated elongation measurement
        
        if estElong>ElongMax  % Don't let the estimated parameter go outside of the bounds
            estElong = ElongMax;
        elseif estElong<ElongMin
            estElong = ElongMin;
        end
        
        q = (estElong-ElongMin)./(ElongMax-ElongMin);  % Calculate the RGB color according to the estimated elongation index
        rgb = [1-q, q, 0];
        
        scatter(clInfo(indMat(i), 1), clInfo(indMat(i), 2), 'MarkerFaceColor', rgb, 'MarkerEdgeColor', 'none');
        hold on
    end
end
end

