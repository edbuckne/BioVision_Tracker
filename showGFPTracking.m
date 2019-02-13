function showGFPTracking( item, pixelH )
%This function takes in an ROI item number and does a scatter plot of
%the tracking sequence.
beginI = item;
trackArray = [];
child = 1;
load('zStacks');

load([pwd '/TRACKING/PC_Relationships']); %Loading the parent child relationships list.
load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information']); %Loading the cell location information

%Find the beginning
while~(PC(beginI,2)==0)
    beginI = PC(beginI,2);
end

%Plot the scatter while also noting the roi locations.
figure
title(['GFP tracking with a moving specimen Item ' num2str(item,'%.2u')])
hold on
i = beginI;
while(child)
    trackArray = [trackArray; clInfo(i,1:3)]; %Store the roi location
    
    if(i==beginI)
        scatter3(clInfo(i,1),clInfo(i,3),pixelH-clInfo(i,2),'*');
    else
        scatter3(clInfo(i,1),clInfo(i,3),pixelH-clInfo(i,2),'o');
    end
    text(clInfo(i,1),clInfo(i,3),pixelH-clInfo(i,2),num2str(i));
    i = PC(i,1); %Get the index of the next time stamp
    if(i==0)
        child=0;
    end
end

line(trackArray(:,1),trackArray(:,3),pixelH-trackArray(:,2));
axis([-pixelH/2 pixelH/2 -pixelH/2 pixelH/2 0 pixelH]); 
end

