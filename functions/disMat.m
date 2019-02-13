function [ D ] = disMat( seg3D1, seg3D2, T12 )
s1 = size(seg3D1);
s2 = size(seg3D2);

CL1 = [seg3D1; ones(1,s1(2))]; %[seg3D1(:,2:4)'; ones(1,s1(1))];
CL2 = [seg3D2; ones(1,s2(2))]; %[seg3D2(:,2:4)'; ones(1,s2(1))];
CL1t = T12*CL1;
D = zeros(s1(2),s2(2));

for i=1:s1(2)
    for j=1:s2(2)
        D(i,j) = sqrt((CL2(1,j)-CL1t(1,i))^2+(CL2(2,j)-CL1t(2,i))^2+(CL2(3,j)-CL1t(3,i))^2);
    end
end

end

