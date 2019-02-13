function BVTmeasure( varargin )
% BVTmeasure.m
%
% A highest level BVT function, takes the segmented information from
% BVTseg3d and makes measurements such as average pixel intensity and shape
% of gene expression regions.

load('data_config');

if(size(varargin,1)==0)
    spm = input('Which specimen do you want to measure? ');
else
    spm = varargin{1};
end
sInd = find(tSpm(:, 1)==spm);
tmStart = tSpm(sInd, 2); tmEnd = tSpm(sInd, 3);
cd(['SPM' num2str(spm,'%.2u')]);
singleZ = false;
if(size(varargin,2)==2)
    tRange = varargin{2};
else
    tRange = tmStart:tmEnd;
end

load('zStacks');
load('cell_location_information');
sCL = size(clInfo);

if exist('shape_info.mat') % If it already exists, just update the existing file instead of assuming all zeros to begin with
    load('shape_info.mat')
else
    shapeInfo = zeros(sCL(1),10);
    statsTot = zeros(tmEnd-tmStart-1,4);
end

disp('Doing mathematical shape representation of each cluster');
for t=tRange
    disp(['Collecting information from time ' num2str(t) ' of ' num2str(tmEnd)])
    timeTot = 0;
    timeTotCount = 0;
    tmStr = num2str(t,'%.4u');
    
    [I,~] = microImInputRaw(spm,t,1,1); %Get the original image
    for z = 1:size(I, 3)
        I(:, :, z) = imgaussfilt(I(:, :, z), 2); % Filter the image to get rid of noise
    end
    sI = size(I);
    if length(sI)==2 % In the case of a 2D image
        singleZ = true;
        I = cat(3, zeros(sI), I, zeros(sI));
        sI = size(I);
    end
    Ireg = zeros(sI); % Holds the 3D segmentation image
    if ~singleZ
        endZ = sI(3);
    else
        endZ = 1;
    end
    for z=1:endZ
        Ireg(:,:,z) = im2double(imread([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr '/SEG_IM.tif'],z));
    end
    
    for i=timeArray(t, 1):timeArray(t, 2) %Look at each element
        if i==0
            continue;
        end
        if~(clInfo(i,10)==t) %Don't consider an element when it's not in the current time stamp
            continue;
        end
        secVal = Ireg(clInfo(i,2),clInfo(i,1),clInfo(i,3)); %Get the value of the section from the COM
        tot = 0; %Used to sum up all pixle values in the region to normalize the curve
        totCount = 0;
        for x=clInfo(i,4):clInfo(i,5)
            for y=clInfo(i,6):clInfo(i,7)
                for z=clInfo(i,8):clInfo(i,9)
                    if(Ireg(y,x,z)==secVal)
                        timeTot = timeTot+I(y,x,z);
                        tot = tot+I(y,x,z);
                        timeTotCount = timeTotCount+1;
                        totCount = totCount+1;
                    end
                end
            end
        end
        
        Ex = clInfo(i,1); %All of the expected values
        Ey = clInfo(i,2); 
        Ez = clInfo(i,3);
        Vx = 0; %Variences
        Vy = 0;
        Vz = 0;
        Cxy = 0; %Covariences
        Cxz = 0;
        Cyz = 0;
        
        Ilog = Ireg==secVal; %Used as a mask for the regions
        Ishape = Ilog.*I; 
        y=clInfo(i,6);
        z=clInfo(i,8);
        for x=clInfo(i,4):clInfo(i,5) %Go through them again getting the covarience information            
            for y=clInfo(i,6):clInfo(i,7)                                
                for z=clInfo(i,8):clInfo(i,9)
                    Vx = Vx+((x-Ex)^2)*Ilog(y,x,z); %V(X)
                    Vy = Vy+((y-Ey)^2)*Ilog(y,x,z); %V(Y)
                    Vz = Vz+((z-Ez)^2)*Ilog(y,x,z); %V(Z)
                    Cxy = Cxy+(x-Ex)*(y-Ey)*Ilog(y,x,z); %C(XY)
                    Cxz = Cxz+(x-Ex)*(z-Ez)*Ilog(y,x,z); %C(XZ)
                    Cyz = Cyz+(y-Ey)*(z-Ez)*Ilog(y,x,z); %C(YZ)
                end
            end
        end
        shapeInfo(i,1) = Vx/totCount; %Vx,Vy,Vz,Cxy,Cxz,Cyz
        shapeInfo(i,2) = Vy/totCount;
        shapeInfo(i,3) = Vz/totCount;
        shapeInfo(i,4) = Cxy/totCount;
        shapeInfo(i,5) = Cxz/totCount;
        shapeInfo(i,6) = Cyz/totCount;
        shapeInfo(i,7) = totCount; %Total number of voxels effected
        shapeInfo(i,8) = tot/totCount; %Average voxel intensity
        shapeInfo(i,9) = tot; %Sum of voxel intensities
        shapeInfo(i,10) = max(Ishape(:)); % Maximum of expression region
    end
    statsTot(t,:) = [timeTotCount timeTot/timeTotCount timeTot timeTotCount*(2*xPix+zPix)]; %Total voxels effected, total average, total sum
    save('shape_info','shapeInfo','statsTot');
end
save('shape_info','shapeInfo','statsTot');
cd ..


end

