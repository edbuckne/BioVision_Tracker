function N = sameFileNumber(spm, id, TH)
N = 0;  % Number of regions within the same file

load(['SPM' num2str(spm, '%.2u') '/cylCoord.mat'])

indMat = 1:length(cylCoord);  % This matrix allows us to manipulate indices callings
siftOut = ~(indMat==id);  % Identify the indices that is not the IOI

xyIOI = cylCoord(id, :);  % Split the data into IOI and not IOI
xyOther = cylCoord(siftOut, :);

for i = 1:size(xyOther, 1)  % Count the number of regions that are within restraints of the TH
    centerDist = abs(xyIOI(2)-xyOther(i, 2));
    ang = abs(xyIOI(3)-xyOther(i, 3));
    
    if centerDist<TH(1) && ang<TH(2)
        N = N+1;
    end
end

end

