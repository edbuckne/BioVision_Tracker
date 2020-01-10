function [ I, minp, maxp ] = spreadPixelRange( I )
%I must be of type double for this function to work properly.
minp = min(I(:));
maxp = max(I(:));
I = (I-minp)./(maxp-minp);
% I1 = min(I,[],3); %Spreading the range of the camera 1 3D image
% minp = min(I1(:));
% I = I-minp;
% I1 = max(I,[],3);
% maxp = max(I1(:));
% I = I./maxp;
end

