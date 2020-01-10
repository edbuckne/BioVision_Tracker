function [Iur, ang] = imturnupright(spm, t, cm, z)
% Loading the image
I3D = microImInputRaw(spm, t, cm, 1);
I = I3D(:, :, z);

Ibw = showMask(spm, t, false);
Ibw = imgaussfilt(Ibw, 80);

r = -45:45;  % Rotate the image to find the upright position (covarience is equal to zero)
Cxy = zeros(length(r), 1);
zCross = ones(length(r), 1);
for i = 1:length(r)
    J = imrotate(Ibw,r(i),'bilinear','crop');
    Cxy(i) = calcCxy(J);
    if ~(i == 1)
        zCross(i) = Cxy(i).*Cxy(i-1);
    end
end

select = zCross<0;
ang = r(select);
ang = ang(1);

Iur = imrotate(I, ang);
imshow(Iur)
end

