spm = 6;
t = 1;

%% Load the 3D image associated with this spm and time
I = microImInputRaw(spm, t, 1, 1);

id = 6;
d = zeros(17, 2);
for id = 1:17
spm = spm;
%% Collect the portion of the image that contains that region
clInfo = loadclInfo(spm);
xRange = clInfo(id, 4):clInfo(id, 5);
yRange = clInfo(id, 6):clInfo(id, 7);
zRange = clInfo(id, 8):clInfo(id, 9);
Iroi = I(yRange, xRange, zRange);
IroiMax = spreadPixelRange(imgaussfilt(max(Iroi, [], 3), 2));

%% Collect the covariance of xy during rotations
r = -90:90;
Cxy = zeros(length(r), 1);

for i = 1:length(r)
    J = imrotate(IroiMax,r(i),'bilinear','crop');
    Cxy(i) = calcCxy(J);
end
d(id, 1) = id;
d(id, 2) = sum(Cxy.^2);
hold on
plot(r, Cxy);
end

% hold on
% plot(r, Cxy);