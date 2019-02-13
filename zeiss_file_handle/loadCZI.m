function [ I1, I2 ] = loadCZI(t)


microData = bfopen(); %Open the czi file

cam1Stack = getCameraData(microData, 1, t);
cam2Stack = getCameraData(microData, 2, t);

s1 = size(cam1Stack);
s2 = size(cam2Stack);

I1 = zeros(s1);
I2 = zeros(s2);

for z=1:s1(3)
    I = im2double(cam1Stack(:,:,z));
    minp = min(I(:));
    I = I-minp;
    maxp = max(I(:));
    I = I./maxp;
    I1(:,:,z) = I;
end

for z=1:s2(3)
    I = im2double(cam2Stack(:,:,z));
    minp = min(I(:));
    I = I-minp;
    maxp = max(I(:));
    I = I./maxp;
    I2(:,:,z) = I;
end

end

