function [Inorm] = localnormalization(I, M)
imS = size(I);
Inorm = zeros(imS);
imzsmooth = I;
for row = 1:imS(1)
    for col = 1:imS(2)
        if imzsmooth(row, col) == 0
            continue;
        end
        row1 = row-M;
        row2 = row+M;
        col1 = col-M;
        col2 = col+M;
        
        if row1<1
            row1 = 1;
        end
        if row2 > imS(1)
            row2 = imS(1);
        end
        if col1 < 1
            col1 = 1;
        end
        if col2 > imS(2)
            col2 = imS(2);
        end
        
        im = imzsmooth(row1:row2, col1:col2);
        im = spreadPixelRange(im);
        Inorm(row, col) = im(round(end/2), round(end/2));
    end
end
end

