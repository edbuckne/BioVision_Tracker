function [ regIm, CL ] = gseg3( I, classObj, sigma, xzrat )
%gseg3 is a function that segments all voxels above the pixel intensity of
%TH (double value). Sigma is the standard deviation used in the gaussian
%kernel filter.  xzrat is the ratio between the zStack physical step and
%the xy physical step in the images.  I is the image to be segmented.  The
%segmentation method used here is gradient decent, with a movement rate of
%Kp, defined below is usually 100.

%sigma=8 is default value
%TH=0.15 is default value
Kp = 2; %Proportional constant
sec = -1; %Sections
trailId = 1; %Starting trail Id at 1
R = 10; %Radius of settling basin
largeIm = 0;

%Find size of the image and resize if it is too big
s = size(I);
if length(s)==2 % In case a 2D image comes in, concatenate blank data to the ends
    I = cat(3, zeros(s), I, zeros(s));
    s = size(I);
end
% if(s(1)>1200)&&(s(2)>1200)
%     warning('Image too big, resizing');
%     largeIm = 1;
%     I2 = zeros(round(s(1)/2),round(s(2)/2),s(3));
%     for z=1:s(3)
%         I2(:,:,z) = imresize(I(:,:,z),[round(s(1)/2),round(s(2)/2)]);
%     end
%     I = I2;
%     clear I2
%     s = size(I);
% end


CL = zeros(5000, 9); %Matrix that holds the cell location information

%Filter each z stack with a Gaussian convolution from the given variance
%sigma
disp('Filtering 3D image')

%Getting the gradient magnitudes and directions
Gx = zeros(s);
Gy = zeros(s);
Iorig = I;
for z=1:s(3)
    I(:,:,z) = imgaussfilt(I(:,:,z),sigma);
    Iorig(:, :, z) = imgaussfilt(Iorig(:, :, z), 2);
    [GmagTmp, GdirTmp] = imgradient(I(:,:,z),'sobel');
    Gx(:,:,z) = GmagTmp.*cosd(GdirTmp);
    Gy(:,:,z) = -1.*GmagTmp.*sind(GdirTmp);
end
clear GmagTmp
clear GdirTmp

Ixz = yStacks(I); %Create orthogonal view images of I in order to get the gradient in the z direciton
disp('Getting gradient in z direction');
I3Gmagy = zeros(s(3),s(2),s(1));
I3Gdiry = zeros(s(3),s(2),s(1));
for y=1:s(1)
    [I3Gmagy(:,:,y), I3Gdiry(:,:,y)] = imgradient(Ixz(:,:,y),'sobel');
end
clear Ixz

Gmagz = yStacks(I3Gmagy); %Undo the orthogonal operator for the gradient
clear I3Gmagy
Gdirz = yStacks(I3Gdiry);
clear I3Gdiry

Gz = -1.*Gmagz.*sind(Gdirz);
clear Gmagz
clear Gdirz


Xs = im2uint16(zeros(s(1),s(2))); %Xs, Ys, and Zs are used for creating the radius
Ys = im2uint16(zeros(s(1),s(2)));
for row=1:s(1)
    for col=1:s(2)
        Xs(row,col) = col;
        Ys(row,col) = row;
    end
end

disp('Thresholding images');
% for z=1:s(3)
%     Ibw(:,:,z) = I(:,:,z)>TH; %Thresholding the image to mask only activity in the GFP channel
% end
Ibw = logical(classifyImage(classObj, I));
Ibw_02 = logical(classifyImage(classObj, Iorig));
xStep = Kp.*Gx.*Ibw; %Proportional gradients
yStep = Kp.*Gy.*Ibw;
clear Gx
clear Gy

disp('Finding cell locations by regional maximum locations');
Ilog1 = imregionalmax3(I).*Ibw; %Finds local maximums of a 3D image

disp('Creating settling regions');
Ilog = zeros(s); %Holds the region settling areas and trails
for z=1:s(3) %Look at each individual z stack's activity
    [r,c] = find(Ilog1(:,:,z)==1); %Find all regional maximums in this z stack
    for i=1:length(r)
        if~(Ilog(r(i),c(i),z)==0) %If the pixel is already assigned to a settling region
            continue; %Ignore it
        end
        CL((-sec),1:3) = [c(i), r(i), z]; %Store cell COM location
        Irg = im2double(sqrt((c(i)-double(Xs)).^2+(r(i)-double(Ys)).^2)<R);
        Ilog(:,:,z) = Ilog(:,:,z) + Irg.*im2double(Ilog(:,:,z)==0).*sec; %Inserting a disk
        if~(z==1)
            Ilog(:,:,z-1) = Ilog(:,:,z-1) + Irg.*im2double(Ilog(:,:,z-1)==0).*sec; %Inserting a disk
        end
        if~(z==s(3))
            Ilog(:,:,z+1) = Ilog(:,:,z+1) + Irg.*im2double(Ilog(:,:,z+1)==0).*sec; %Inserting a disk
        end
        sec = sec-1;
    end
end
% for z=1:s(3) %Going through each element in the logical image and adding disks
%     for row=1:s(1)
%         for col=1:s(2)
%             if(Ilog1(row,col,z)==1) %If this is the location of a local maximum                
%                 if~(Ilog(row,col,z)==0) %If the pixel is already assigned to a settling region
%                     continue; %Ignore it
%                 end
%                 CL((-sec),1:3) = [col, row, z]; %Store cell COM location
%                 Irg = im2double(sqrt((col-double(Xs)).^2+(row-double(Ys)).^2)<R); 
%                 Ilog(:,:,z) = Ilog(:,:,z) + Irg.*im2double(Ilog(:,:,z)==0).*sec; %Inserting a disk
%                 if~(z==1)
%                     Ilog(:,:,z-1) = Ilog(:,:,z-1) + Irg.*im2double(Ilog(:,:,z-1)==0).*sec; %Inserting a disk
%                 end
%                 if~(z==s(3))
%                     Ilog(:,:,z+1) = Ilog(:,:,z+1) + Irg.*im2double(Ilog(:,:,z+1)==0).*sec; %Inserting a disk
%                 end
%                 sec = sec-1;
%             end
%         end
%     end
% end
clear Ilog1

CL = CL(1:(-sec)-1,:);
CL(:,4) = CL(:,1); %This is so we can find minimums
CL(:,6) = CL(:,2);
CL(:,8) = CL(:,3);


regIm = zeros(s); %Final image that will contain the segmented regions
trailM = int16(zeros(s(1).*s(2),1)); %Vector that tells which trails belong to which regions
disp('Segmenting regions');
for z=1:s(3) %Going through each element in the proportional gradient matrices
    for row=1:s(1)
        for col=1:s(2)
            if(Ibw(row,col,z)==0) %Don't consider areas not found in the mask image
                continue;
            end
            xd = col; %Dynamic pixel starts at the static pixel location
            yd = row;
            zd = z;
            while(Ilog(yd,xd,zd)==0) %As long as we are seeing pixels that have never seen activity
                Ilog(yd,xd,zd) = trailId; %Mark trail
                
                %Find new dynamic pixel
                delx = xStep(yd,xd,zd); %New delta x and y
                dely = yStep(yd,xd,zd);
                
                %Calculating the z step
                if~(zd==1||zd==s(3)) %Demorgans law for z is not at the edges
                    delz = Gz(yd,xd,zd); %Gradient in z direction
                    if~(delz==0) %z gradient can only be 1 or -1
                        delz = double(-(delz<0)+(delz>0));
                    else 
                        delz=0;
                    end
                elseif(zd==s(3))
                    delz = double((I(yd,xd,zd)-I(yd,xd,zd-1))<0)*(-1); %Gradient is 0 or negative
                else %zd has to be 1
                    delz = double((I(yd,xd,zd+1)-I(yd,xd,zd))>0); %Gradient is 0 or positive
                end
                
                if(abs(delx)<1) %Proportional x step
                    delx = double((delx>0) - (delx<0));
                else
                    delx = round(delx);
                end
                if(abs(dely)<1) %Proportional y step
                    dely = double((dely>0) - (dely<0));
                else
                    dely = round(dely);
                end
                
                xd = xd+delx; %Quick increments
                yd = yd+dely;
                zd = zd+delz;
                
                if(yd>s(1)||yd<1||xd>s(2)||xd<1||zd>s(3)||zd<1) %Check if dynamic pointer goes outside of image
                    break;
                end
                if(Ibw(yd,xd,zd)==0) %If the dynamic pixel drifts out of the mask image
                    break;
                end
            end

            if(yd>s(1)||yd<1||xd>s(2)||xd<1||zd>s(3)||zd<1) %Check if dynamic pointer goes outside of image
                disV = sqrt((CL(:,1)-col).^2+(CL(:,2)-row).^2+(CL(:,3).*xzrat-z*xzrat).^2); %Distance from COM locations
                [~,location] = min(disV);
                if isempty(location)
                    break;
                end
                trailM(trailId) = -location(1);
                regIm(row,col,z) = -1*trailM(trailId); %Store in region Image
                trailId = trailId+1;
                continue;
            end
            if(Ibw(yd,xd,zd)==0||Ilog(yd,xd,zd)==trailId)
                disV = sqrt((CL(:,1)-col).^2+(CL(:,2)-row).^2+(CL(:,3).*xzrat-z*xzrat).^2); %Distance from COM locations
                [~,location] = min(disV);
                if isempty(location)
                    break;
                end
                trailM(trailId) = -location(1);
                regIm(row,col,z) = -1*trailM(trailId); %Store in region Image
                trailId = trailId+1;
                continue;
            end
            
            if(Ilog(yd,xd,zd)<0) %We have found a settling region
                if trailId<(s(1)*s(2))
                    trailM(trailId) = Ilog(yd,xd,zd);
                else
                    trailM = [trailM; Ilog(yd,xd,zd)];
                end
%                 trailM(trailId) = Ilog(yd,xd,zd);
            else %We have found an old trail
                if trailId<(s(1)*s(2))
                    trailM(trailId) = trailM(Ilog(yd,xd,zd));
                else
                    trailM = [trailM; trailM(Ilog(yd,xd,zd))];
                end
%                 trailM(trailId) = trailM(Ilog(yd,xd,zd));
            end
            regId = -1*trailM(trailId);
            regIm(row,col,z) = regId; %Store in region Image of the static pixel
            trailId = trailId+1;
            if regId==0
                continue;
            end
            rCL = CL(regId,:);
            
            if(col<rCL(4)) %New x1 or x2
                CL(regId,4)=col;
            elseif(col>rCL(5))
                CL(regId,5)=col;
            end
            if(row<rCL(6)) %New y1 or y2
                CL(regId,6)=row;
            elseif(row>rCL(7))
                CL(regId,7)=row;
            end
            if(z<rCL(8)) %New z1 or z2
                CL(regId,8)=z;
            elseif(z>rCL(9))
                CL(regId,9)=z;
            end
        end
    end
end

trailM = trailM(1:trailId-1);

disp('Finalizing region image');
maxp = max(regIm,[],3);
maxp = max(maxp(:));
regIm = (im2double(regIm)./maxp).*Ibw_02;

if(largeIm)
    CL(:,1:2) = CL(:,1:2).*2;
    CL(:,4:7) = CL(:,4:7).*2;
end
end

