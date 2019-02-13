function showGFP( TM, SCALE, OPT, ITEM)
%This function takes in a time stamp from the data and displays the region
%of interests within the specimen with a corresponding item number;
xSpread = 100;
varX = 50;
clPresent = 0;

if exist('zStacks.mat','file')
    load('zStacks');
end
if exist('data_config.mat','file')
    load('data_config');
end
if exist([pwd '/TRACKING/PC_Relationships.mat'],'file');
    load([pwd '/TRACKING/PC_Relationships']); %Load the time Array and PC
end
if exist([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information.mat'],'file')
    load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information']); %Load cell locations
    clPresent = 1;
end
if exist([pwd '/ROOT_BORDER/AC_Multiview_Info_TM' num2str(TM,'%.4u') '.mat'],'file')
    load([pwd '/ROOT_BORDER/AC_Multiview_Info_TM' num2str(TM,'%.4u')]); %Load active contour
else 
    error('No reconstruction data to use');
end

x = -xSpread:xSpread;
norm = normpdf(x,0,varX);

[maxY1,maxY1I] = max(ACRAWV1(2,:)); %Get the shifting information
maxX1 = ACRAWV1(1,maxY1I);
[maxY2,maxY2I] = max(ACRAWV2(2,:));
maxX2 = ACRAWV2(1,maxY2I);

logVar1 = 1:length(ACV1(1,:)); %Make a variable to use for logical operations
logVar2 = 1:length(ACV2(1,:)); 

convAC11 = conv(ACV1(1,:),norm); %Convolving the data to get a filtered answer
convAC13 = conv(ACV1(3,:),norm);
convAC21 = conv(ACV2(1,:),norm);
convAC23 = conv(ACV2(3,:),norm);

convAC11 = convAC11(xSpread:end-xSpread-1); %Taking out the tails of the filtered data
convAC13 = convAC13(xSpread:end-xSpread-1);
convAC21 = convAC21(xSpread:end-xSpread-1);
convAC23 = convAC23(xSpread:end-xSpread-1);

convAC11(logVar1<xSpread) = convAC11(xSpread+1); %Deleting more of the tail
convAC11(logVar1>end-xSpread) = convAC11(end-xSpread-1);
convAC13(logVar1<xSpread) = convAC13(xSpread+1);
convAC13(logVar1>end-xSpread) = convAC13(end-xSpread-1);
convAC21(logVar2<xSpread) = convAC21(xSpread+1);
convAC21(logVar2>end-xSpread) = convAC21(end-xSpread-1);
convAC23(logVar2<xSpread) = convAC23(xSpread+1);
convAC23(logVar2>end-xSpread) = convAC23(end-xSpread-1);


figure
hold on
title(['Cell locations for TM' num2str(TM,'%.4u')]);
plot3(convAC11,convAC13,ACV1(2,:),'b');
plot3(convAC23,convAC21,ACV2(2,:),'b');

color = 1;
count = 0;
if(clPresent) %only if we have cell locations do we present cell locations
    if(OPT == 1)
        b = timeArray(TM,1); %Get the range index for where this time stamp is in the CL list
        e = timeArray(TM,2);
        
        zN = (zStacks(TM,3)*xyratz)/2; %Get the scale of z shift
        
        scatter3(clInfo(b:e,1)-maxX1,clInfo(b:e,3)*xyratz-zN,maxY1-clInfo(b:e,2),zeros(e-b+1,1)+4);
        for i=b:e
              text(clInfo(i,1)-maxX1,clInfo(i,3)*xyratz-zN,maxY1-clInfo(i,2),num2str(i));
        end
    else
        hold on
        I = imread([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' num2str(TM,'%.4u') '/SEG_IM.tif'],1); %Get first segmentation image
        sI = size(I);
        I = zeros(sI(1),sI(2),zStacks(TM,3));  
        for z=1:zStacks(TM,3)
            I(:,:,z) = imread([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' num2str(TM,'%.4u') '/SEG_IM.tif'],z);
        end
        offset = zStacks(TM,3)*xyratz/2;
        if (ITEM>0)
            regId = I(clInfo(ITEM,2),clInfo(ITEM,1),clInfo(ITEM,3));
            for row=1:3:sI(1)
                row
                for col=1:3:sI(2)
                    for z=1:zStacks(TM,3)
                        if(I(row,col,z)==regId)
                                scatter3(col-maxX1,z*xyratz-offset,maxY1-row,1,'g');
                        end
                    end
                end
            end
        else
            for ITEM = timeArray(TM,1):timeArray(TM,2)
                if(mod(color,4)==0)
                    colStr = 'g';
                elseif(mod(color,4)==1)
                    colStr = 'r';
                elseif(mod(color,4)==2)
                    colStr = 'b';
                else
                    colStr = 'm';
                end
                regId = I(clInfo(ITEM,2),clInfo(ITEM,1),clInfo(ITEM,3));
                for row=clInfo(ITEM,6):10:clInfo(ITEM,7)
                    for col=clInfo(ITEM,4):10:clInfo(ITEM,5)
                        for z=clInfo(ITEM,8):clInfo(ITEM,9)
                            if(I(row,col,z)==regId)
                                scatter3(col-maxX1,z*xyratz-offset,maxY1-row,1,colStr);
                            end
                        end
                    end
                end
                color = color+1;
            end
        end
    end
end
axis([-SCALE(1)/2 SCALE(1)/2 -SCALE(1)/2 SCALE(1)/2 0 SCALE(2)]);
view([15 5])
end

