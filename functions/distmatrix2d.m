function M = distmatrix2d(P1, P2)
M = zeros(size(P1, 1), size(P2, 1));
s = size(M);
for row = 1:s(1)
    for col = 1:s(2)
        M(row, col) = sqrt((P1(row, 1)-P2(col, 1)).^2 + (P1(row, 2)-P2(col, 2)).^2);
    end
end
end

