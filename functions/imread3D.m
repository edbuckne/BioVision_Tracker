function I3d = imread3D(path)
info = imfinfo(path);
zLength = length(info);
I3d = zeros(info(1).Height, info(1).Width, zLength);

for z = 1:zLength
    I3d(:, :, z) = imread(path, z);
end
end

