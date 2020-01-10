function point = indicatePointOnSPM(spm, t, cm)
I = microImInputRaw(spm, t, cm, 1);
figure
imshow3D(I);
input('Press enter when you get to a good z stack');

[x, y] = ginput(1);
close all

point = [x, y];
end

