function [ei, cLen] = elongationIndex(spm, id, I)
clInfo = loadclInfo(spm);  % Get the information from segmentation
shapeInfo = loadshape_info(spm);
% if shapeInfo(id, 7)<20
%     ei = -1;
%     cLen = -1;
%     return
% end
t = clInfo(id, 10);
I3dSeg = load3DSeg(spm, t);  % Get the 3D segmentation image
if ~exist('I', 'var')
    I = microImInputRaw(spm, t, 1, 1);
end    
S = size(I);
   
[X, Y, Z] = meshgrid(1:S(2), 1:S(1), 1:S(3));
ixyz = clInfo(id, 1:3); 
segVal = I3dSeg(ixyz(2), ixyz(1), ixyz(3));
if segVal==0
    ei = -1;
    cLen = -1;
    return;
end
Irg = imregiongrow3dbw(double(I3dSeg==segVal), ixyz);

Xlist = Irg.*X;
XlistFlat = Xlist(Xlist>0);
Ylist = Irg.*Y;
YlistFlat = Ylist(Ylist>0);
Zlist = Irg.*Z;
ZlistFlat = Zlist(Zlist>0);

minX = min(XlistFlat); maxX = max(XlistFlat);
minY = min(YlistFlat); maxY = max(YlistFlat);
minZ = min(ZlistFlat); maxZ = max(ZlistFlat);

xRange = minX:maxX;
yRange = minY:maxY;
zRange = minZ:maxZ;

Iroi = I(yRange, xRange, zRange);
IroiMax = spreadPixelRange(imgaussfilt(max(Iroi, [], 3), 2));

r = -90:90;
Cxy = zeros(length(r), 1);

Cxy = calcCxy(IroiMax);
[Vx, Vy] = calcVxVy(IroiMax);

% try
%     [~, J] = eig([Cxy, Vx; Vy, Cxy]);
%     eig1 = abs(J(1, 1)); eig2 = abs(J(2, 2));
% catch
%     ei = -1;
%     cLen = -1;
%     return;
% end


% if eig2>eig1
%     ei = 1-eig1./eig2;
%     cLen = eig2;
% else
%     ei = 1-eig2./eig1;
%     cLen = eig1;
% end

for i = 1:length(r)
    J = imrotate(IroiMax,r(i),'bilinear','crop');
    Cxy(i) = calcCxy(J);
end
ei = log(sum(Cxy.^2));
end

