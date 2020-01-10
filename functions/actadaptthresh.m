function Iath = actadaptthresh(I, ydata, thdata, wdata)
    linreg = [ones(2, 1), ydata']\wdata';
    linreg2 = [ones(2, 1), ydata']\thdata';
    S = size(I);
    Iath = zeros(S);
    
    [~, yim] = meshgrid(1:S(2), 1:S(1));
    
    linregim = linreg(1) + linreg(2) .* yim;
    linregim = round((linregim-1) ./ 2);
    linregim = (linregim .* 2) + 1;
    linreg2im = linreg2(1) + linreg2(2) .* yim;
    
    linregim(linregim < min(wdata)) = min(wdata);
    linregim(linregim > max(wdata)) = max(wdata);
    linreg2im(linreg2im < min(thdata)) = min(thdata);
    linreg2im(linreg2im > max(thdata)) = max(thdata);

    f = waitbar(0,'Running Active Adaptive Threshold');   
    for row = 1:S(1)
        waitbar(row/S(1),f,['Running Active Adaptive Threshold: ' num2str((row./S(1)).*100) '%']);
        for col = 1:S(2)
            W = linregim(row, col);
            L = (W-1)/2;  % The buffer room around the filter
            P = linreg2im(row, col);
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
    close(f);
end

