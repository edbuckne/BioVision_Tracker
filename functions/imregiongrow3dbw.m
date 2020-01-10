function Iout = imregiongrow3dbw(I, xyz)
S = size(I);
Iout = zeros(S);
Iout(xyz(2), xyz(1), xyz(3)) = 1;
addPoint = [1, 0, 0; -1, 0, 0; 0, 1, 0; 0, -1, 0; 0, 0, 1; 0, 0, -1];

stackList = xyz;

while ~isempty(stackList)
    Icheck = I-Iout;
    poi = stackList(1, :);  % Point of interest
    for p = 1:size(addPoint, 1)
        poiAdd = poi+addPoint(p, :);
        try
            if Icheck(poiAdd(2), poiAdd(1), poiAdd(3))==1
                Iout(poiAdd(2), poiAdd(1), poiAdd(3)) = 1;
                stackList = [stackList; poiAdd];
            end
        catch
            continue;
        end
    end
    if size(stackList, 1) == 1
        break;
    else
        stackList = stackList(2:end, :);
    end
end

end

