function BVTregionMerge(varargin)

% BVTregionMerge.m is a function at the highest level of the BVT framework.
% This function merges the segmented regions (indicated by BVTseg3d) that
% are touching and makes them 1 region.

load('./data_config');

if isempty(varargin) % Get the specimen number
    spm = input('Input the specimen identifier number: ');
else
    spm = varargin{1};
end

spmdir = ['SPM' num2str(spm, '%.2u')]; % Load data files from BVTseg3d
load([spmdir '/cell_location_information']);

clInfo2 = [];

T = size(timeArray, 1); % How many time stamps for this specimen
for t = 1:T % Go through each time stamp
    segname = ['SPM' num2str(spm, '%.2u') '/3D_SEG/SPM' num2str(spm, '%.2u') '/TM' num2str(t, '%.4u') '/SEG_IM.tif'];
    I3dSeg = load3DSeg(spm, t); % Load the 3D segmented image
    newSeg = I3dSeg;
    S = size(I3dSeg);
    
    segmask = I3dSeg > 0;
    CC = bwconncomp(segmask);
    clInfo = zeros(CC.NumObjects, 10);
    
    [xim, yim, zim] = meshgrid(1:S(2), 1:S(1), 1:S(3));
    for i = 1:CC.NumObjects
        newSeg(CC.PixelIdxList{i}) = i;
        
        regionmask = double(newSeg == i); % Collect new data about region
        xmask = xim.*regionmask;
        ymask = yim.*regionmask;
        zmask = zim.*regionmask;
        xlist = xmask(xmask > 0); % Mask the mesh
        ylist = ymask(ymask > 0);
        zlist = zmask(zmask > 0);
        xcom = round(mean(xlist)); % Collect corresponding data
        ycom = round(mean(ylist));
        zcom = round(mean(zlist));
        x1 = min(xlist);
        x2 = max(xlist);
        y1 = min(ylist);
        y2 = max(ylist);
        z1 = min(zlist);
        z2 = max(zlist);
        
        clInfo(i, :) = [xcom, ycom, zcom, x1, x2, y1, y2, z1, z2, t]; % New data
    end
    
%     trigger = 1;
%     while (trigger > 0)&&(iter<10)
%         if iter == 1
%             mergedreg = 0;
%         else
%             mergedreg = trigger;
%         end
%         disp(['Iteration: ' num2str(iter), ', Merged regions: ' num2str(mergedreg)]);
%         trigger = 0;
%         for i = timeArray(t, 1):timeArray(t, 2) % Go through all segmented regions and gather the segmentation value
%             if (iter > 1)&&(clInfo(i, 1)==0) % Doesn't exist anymore
%                 continue;
%             end
%             segval(i) = I3dSeg(clInfo(i, 2), clInfo(i, 1), clInfo(i, 3));
%         end
%         
%         for i = timeArray(t, 1):timeArray(t, 2) % Go through all segmented regions again
%             if (iter > 1)&&(clInfo(i, 1)==0)||(segval(i)==0) % Doesn't exist anymore
%                 continue;
%             end
%             regionmask = double(I3dSeg == segval(i)); % Isolate this region in a mask image
%             
%             bw1 = zeros(size(regionmask)); % Create a distance from region image
%             for z = 1:size(bw1, 3)
%                 if sum(sum(regionmask(:, :, z))) == 0
%                     continue;
%                 end
%                 bw1(:, :, z) = bwdist(regionmask(:, :, z));
%             end
%             
%             for j = timeArray(t, 1):timeArray(t, 2) % Embeded loop to check all other regions
%                 if (iter > 1)&&(clInfo(j, 1)==0)||(segval(j)==0) % Doesn't exist anymore
%                     continue;
%                 end
%                 if (j==i) % Skip if the regions are the same
%                     continue;
%                 end
%                 
%                 regionmask2 = double(I3dSeg == segval(j)); % Also isolate this region
%                 bw2 = zeros(size(regionmask2)); % Create a distance from region image
%                 for z = 1:size(bw2, 3)
%                     if sum(sum(regionmask2(:, :, z))) == 0
%                         continue;
%                     end
%                     bw2(:, :, z) = bwdist(regionmask2(:, :, z));
%                 end
%                 
%                 bwmult = bw1 .* bw2; % Check adjoining regions
%                 bwmask = bwmult(bwmult>0);
%                 mindist = min(bwmask(:));
%                 if mindist < 2
%                     trigger = trigger + 1;
%                     if clinfonew(i) > 0
%                         clinfonew(j) = clinfonew(i);
%                     else
%                         clinfonew(j) = i;
%                     end
%                 end
%             end
%         end
%         clear regionmask
%         clear regionmask2
%         clear bw1
%         clear bw2
%         
%         % Merge regions
%         oldclInfo = clInfo;
%         oldsegim = I3dSeg;
%         [xim, yim, zim] = meshgrid(1:S(2), 1:S(1), 1:S(3));
%         for i = timeArray(t, 1):timeArray(t, 2)
%             if (iter > 1)&&(clInfo(i, 1)==0) % Doesn't exist anymore
%                 continue;
%             end
%             if clinfonew(i) == 0 % This region is not touching another
%                 continue;
%             elseif clinfonew(i) == i % The region is to merge on itself
%                 continue;
%             else
%                 trigger = trigger + 1;
%                 I3dSeg(I3dSeg == segval(i)) = segval(clinfonew(i)); % This combined regions into 1
%                 
%                 regionmask = double(I3dSeg == segval(clinfonew(i))); % Collect new data about region
%                 xmask = xim.*regionmask;
%                 ymask = yim.*regionmask;
%                 zmask = zim.*regionmask;
%                 xlist = xmask(xmask > 0); % Mask the mesh
%                 ylist = ymask(ymask > 0);
%                 zlist = zmask(zmask > 0);
%                 xcom = round(mean(xlist)); % Collect corresponding data
%                 ycom = round(mean(ylist));
%                 zcom = round(mean(zlist));
%                 x1 = min(xlist);
%                 x2 = max(xlist);
%                 y1 = min(ylist);
%                 y2 = max(ylist);
%                 z1 = min(zlist);
%                 z2 = max(zlist);
%                 
%                 clInfo(clinfonew(i), :) = [xcom, ycom, zcom, x1, x2, y1, y2, z1, z2, t]; % New data
%                 clInfo(i, :) = clInfo(i, :) .* 0; % Erase old data
%                 clinfonew(i) = 0;
%             end
%         end
%         clinfonew = clinfonew .* 0;
%         iter = iter + 1;
%     end
%     
    disp('Region merging successfull');
    delete(segname); % Replace segmentation image
    z = 1;
    while z <= S(3)
        try
            imwrite(uint16(newSeg(:, :, z)), segname, 'writemode', 'append');
            z = z + 1;
        catch
            continue;
        end
    end
clInfo2 = [clInfo2; clInfo];
end

clInfo = clInfo2;
% clInfo = clInfo(clInfo(:, 1)>0, :); % Update and save new information
timeArray = updatetimeArray(clInfo);
save([spmdir '/cell_location_information'], 'clInfo', 'timeArray');
end