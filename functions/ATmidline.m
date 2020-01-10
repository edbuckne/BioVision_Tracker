function [ S, Imask ] = ATmidline( I, varargin )
% ATmidline.m - This function takes in a 3D brightfield image of an
% Arabidopsis thaliana root taken from a light sheet microscope and
% determines a midline that describes the central axis of the root. 
%
% INPUT:
%   I - 3D brightfield image.
%   varargin - Display option
%       'mp' - maximum gradient projection
%       'mask' - logical image segmenting root from background
%       'ml' - midline shown on the maximum projection image
%       'ol' - outline of the root
%       'th' - Initial threshold estimate based on k-means algorithm
%
% OUTPUT:
%   S - Variable that holds the x values associated with the midline. The y
%   values are the indices of S starting at 1.
%   Imask - 2D mask image of the root classifying pixels as specimen or
%   background.

Igrad = zeros(size(I)); % 3D gradient magnitude matrix
% if mean(I(:))<0.1
%     S = [];
%     Imask = max(Igrad, [], 3);
%     return;
% end
for z = 1:size(I, 3)
    Igrad(:, :, z) = imgradient(imgaussfilt(I(:, :, z), 2));
end
Igmp = max(Igrad, [], 3); % Maximum gradient projection

[~, C] = kmeans(Igmp(:), 2); % K-means clustering to separate specimen from background
th = mean(C);
Ith = Igmp>th; % Threshold image
Ith2 = Ith; % Used to fill the holes in the top of the root
Ith2(1, :) = ones(1, size(I, 2)); % Fill the top row of pixels as white
Ith2(end, :) = ones(1, size(I, 2)); % Fill the bottom row of pixels as white
Ith = imgaussfilt(double(imfill(Ith, 'holes')), 2)>0.5;
Ith2 = imgaussfilt(double(imfill(Ith2, 'holes')), 2)>0.5;
if sum(Ith(:))==0
    S = [];
    Imask = Ith;
    return;
end
Ith2(1, :) = Ith2(2, :);
Ith2(end, :) = Ith2(end-1, :);

CC = bwconncomp(Ith2); % Find the connecting regions

Imask = zeros(size(Ith2)); % Image to hold the mask

if length(CC.PixelIdxList)>1 % There are more than one segmented island
    maxSize = 0;
    maxIdx = 0;
    for i = 1:length(CC.PixelIdxList) % Find the biggest island and use that one
        s = length(CC.PixelIdxList{i});
        if s>maxSize
            maxSize = s;
            maxIdx = i;
        end
    end
    Imask(CC.PixelIdxList{maxIdx}) = 1;
else % Use the only island we have
    Imask(CC.PixelIdxList{1}) = 1;
end

maskSize = size(Imask); % Create the variable to hold the midline
S = zeros(maskSize(1), 1);
colNums = 1:maskSize(2);

for i = 1:maskSize(1)
    rowdata = Imask(i, :); % Get the values in this row and normalize
    rowdata = rowdata./sum(rowdata);
    
    mp = sum(colNums.*rowdata); % Find the midpoint
    if isnan(mp)&&(i==1)
        S = [];
        break;
    elseif isnan(mp)&&(i>1)
        S = S(1:(i-1));
        break;
    else
        S(i) = mp;
    end
end

filtOrder = round(maskSize(1)./10); % Run data through a lowpass filter
b = ones(filtOrder, 1)./filtOrder;
S = round(filtfilt(b, 1, S));

% data = filtfilt(ones(1, 40)/40, 1, double(Ith(1, :))); % Filter the first row of the th image
% data = Ith2(2, :);
% potL = [];
% state = 'low';
% for x=1:size(Ith, 2) % Obtain all points that switch states to assess starting point for tracking algorithm
%     if (strcmp(state,'low') && data(x)>0.5 && Ith(1,x)==1)
%         state = 'high';
%         potL = [potL; x 1];
%     elseif (strcmp(state,'high') && data(x)<0.5)
%         state = 'low';
%         potL = [potL; x 0];
%     end
% end
% if isempty(potL)
%     S = [];
%     Imask = Ith;
%     return;
% end
% 
% for hello=1:20
%     D = pdist(potL(:, 1)); % Find the pair of points closest to ~150 microns across
%     Z = squareform(D);
%     Z450 = abs(Z-450); % Typical AT width is 450 pixels across
%     [~, ind] = min(Z450(:));
%     [~, L] = ind2sub(size(Z450), ind);
%     x = potL(L, 1); % This is the starting x point used for the tracing algorithm
%     potL(L, 1) = Inf;
%     
%     % Making sure that we aren't tracing just a small patch of mask
%     count = 0;
%     xStart = x;
%     while x<size(I, 2)       
%         if Ith(1, x)==1
%             if count==0
%                 xStart = x;
%             end
%             count = count+1;
%         else
%             count = 0;
%         end
%         if count>=20
%             break;
%         end
%         x = x+1;
%     end
%     x = xStart;
%     B = bwtraceboundary(Ith2, [1, x], 'w', 8, Inf, 'counterclockwise'); % Tracing algorithm
%     if(size(B, 1)>100)
%         break;
%     else
%         continue;
%     end
% end
% 
% lB = size(B, 1)/8;
% i = 2;
% while(B(i, 1)==1 && B(i, 2)<B(1, 2))
%     i = i+1;
% end
% B = B(i:end, :);
% i = 1;
% while(~(B(i, 1)==1) || i<lB || B(i, 2)<B(1, 2)) % Find where the trace comes back to the top of the image
%     i = i+1;
% end
% yEnd = B(i, 1); xEnd = B(i, 2); % Note that point
% i = i+1;
% while(~(xEnd==B(1, 2))) % Trace that point back to the staring position
%     xEnd = xEnd-1;
%     B(i, 2) = xEnd; B(i, 1) = 1;
%     i = i+1;
% end
% B = B(1:i-1, :);
% 
% CT = zeros(size(Igmp));
% for i = 1:size(B, 1)
%     CT(B(i, 1), B(i, 2)) = 1; % Fill in an image of points to create a mask
% end
% Imask = imfill(CT, 'holes'); % Create that mask
% 
% [Ytip, ~] = max(B(:, 1)); % Find the tip of the root to indicate the length of the midline
% 
% x = 1:size(Ith, 2); % Finding the midline using the concept of expected value in a uniform distribution
% Ymid = zeros(Ytip, 1);
% for row = 1:Ytip
% %     integ = sum(double(Ith(row, :)));
%     integ = sum(double(Imask(row, :)));
% %     expOut = sum(x.*double(Ith(row, :))./integ);
%     expOut = sum(x.*double(Imask(row, :))./integ);
%     Ymid(row) = round(expOut);
% end
% b = ones(1,100)/100; % Non-causal filter used for midline
% if length(Ymid)<300
%     S = [];
%     Imask = Imask.*0;
%     return;
% end
% S = filtfilt(b, 1, Ymid); % Midline creation

if(size(varargin,1)>0)
    switch(varargin{1})
        case 'mp'
            figure;
            imshow(Igmp);
        case 'mask'
            figure;
            imshow(Imask);
        case 'ml'
            figure;
            imshow(Igmp);
            hold on
            plot(S, 1:Ytip, 'LineWidth', 1.5);
        case 'ol'
            figure
            imshow(Ith);
            hold on
            plot(B(:, 2), B(:, 1), 'LineWidth', 1.5);
        case 'th'
            figure
            imshow(Ith);
        otherwise
            % Do nothing
    end
end

end

