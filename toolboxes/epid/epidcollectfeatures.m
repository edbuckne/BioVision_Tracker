function [X] = epidcollectfeatures(Iout, imz, P, latres, varargin)
% epidcollectfeatures.m takes in an already segmented image of plant cells
% (Iout) which is a grayscale image that contains labels for each pixel
% corresponding with every other pixel with the same value, the original grayscale 
% image (imz), and an Nx2 array (P) that holds the x and y location for each
% detected cell in the image. Iout, imz, and P can be collected by the function
% segmentCells.m. This function will then return the Nx10 dimensional array
% (X) that contains features specific to detecting epidermal cells.

defaultMaskNetwork = 'UNET';  % Name of the network to mask the root

p = inputParser;
addRequired(p, 'Iout');
addRequired(p, 'imz');
addRequired(p, 'P');
addRequired(p, 'latres');
addParameter(p, 'MaskNetwork', defaultMaskNetwork);
parse(p, Iout, imz, P, latres, varargin{:});

imgrad = imgradient(imz);
imzfilt = imgaussfilt(imz, 3);
imth = predictrootmaskunet(imz, 'MaskNetwork', p.Results.MaskNetwork);
imD = bwdist(logical(1-imth)).*latres;  % Physical distance from a white region

% figure
% imshow(imz)
% hold on

X = zeros(size(P, 1), 10);  % high-dimensional data, # of columns is number of features
ce = zeros(size(P, 1), 1);  % Contour energy variable
for i = 1:size(P, 1)  % Go through each point in the cell list and collect features
    pointloc = P(i, 1:2);  % Location of the point
    pointval = Iout(pointloc(2), pointloc(1));  % Value of that segmented region
    imroi = double(Iout == pointval);  % Mask the region of interest
    imroiraw = imz.*imroi;  % Extract the mask of the region from the raw image
    
    Iedge = double(edge(imroi));  % Makes an image of the edges of our region
    
    pixSize = sum(imroi(:));  % Size of roi
    perSize = sum(Iedge(:));  % Perimeter of roi
    
    Ifilt = imgaussfilt(imroi, 6);  % Major and minor axis calculation
    Cxy = calcCxy(Ifilt);
    [Vx, Vy] = calcVxVy(Ifilt);
    D = [Cxy, Vx; Vy Cxy];
    J = eig(D);
    [M1, J1] = eig(D);
    Jabs = abs(J);
    [~, maxi] = max(abs(J));
%     quiver(P(i, 1), P(i, 2), 10.*M1(maxi, 1), 10.*M1(maxi, 2));
    
    eigDiff = abs(Jabs(1) - Jabs(2));
    eigRat = max(Jabs)/min(Jabs);
    
    distval = imD(pointloc(2), pointloc(1));  % Distance from an edge of the root
    
    intavg = mean(imroiraw(imroiraw>0));  % Information about the intensities of the segmented regions
    intvar = var(imroiraw(imroiraw>0));
    
    impergrad = Iedge .* imgrad;  % Parameter gradient sum
    pergrad = mean(impergrad(:));
    
    imgradint = imroi .* imgrad; % Region gradient sum
    gradavg = mean(imgradint(imgradint>0));
    gradvar = var(imgradint(imgradint>0));
    
    [indimx, indimy] = meshgrid(1:size(imz, 2), 1:size(imz, 1));  % Contour energy
    edgeindx = indimx.*Iedge;
    edgeindy = indimy.*Iedge;
    edgevalx = edgeindx(edgeindx>0);
    edgevaly = edgeindy(edgeindy>0);
    delx = diff(edgevalx);
    deldelx = diff(delx);
    dely = diff(edgevaly);
    deldely = diff(dely);
    enmag = sqrt(deldelx.^2+deldely.^2);
    ce(i) = mean(enmag);
    
    insert = [pixSize, perSize, eigDiff, eigRat, distval, intavg, intvar, pergrad, gradavg, gradvar];
    
    
    X(i, :) = insert; 
end
end

