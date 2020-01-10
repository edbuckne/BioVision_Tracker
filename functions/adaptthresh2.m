function [Iath] = adaptthresh2(I, W, P)
S = size(I);  % Get the size of the image
Iath = zeros(S);

if mod(W, 2)==0
    error('The window size (W) must be an odd number');
end

if P<0 || P>1
    error('The percentage value (P) must be between 0 and 1');
end

L = (W-1)/2;  % The buffer room around the filter

for row = 1:S(1)
    for col = 1:S(2)
        rowMin = row-L; rowMax = row+L;
        colMin = col-L; colMax = col+L;
        
        if rowMin<1  % Bound the rows to within the image
            rowMin = 1;
        elseif rowMax>S(1)
            rowMax = S(1);
        end
        
        if colMin<1  % Bound the cols to within the images
            colMin = 1;
        elseif colMax>S(2)
            colMax = S(2);
        end
        
        Ir = I(rowMin:rowMax, colMin:colMax);
        ptl = prctile(Ir(:), P*100);
        Iath(row, col) = double(I(row, col)>ptl);
        
    end
end


end

