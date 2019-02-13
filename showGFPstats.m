function showGFPstats( item )
if~(item==0)
    beginI = item;
else
    beginI = 1;
end
statsArray = [];
child = 1;

load('zStacks');
load('data_config');
load([pwd '/TRACKING/PC_Relationships']);
load([pwd '/SHAPE_INFO/shape_info']);
load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information']); %Loading the cell location information

while~(PC(beginI,2)==0) %Find the beginning item
    beginI = PC(beginI,2);
end

i = beginI;
if(item<=0)
    figure
    hold on
    title('Average pixel intensity for entire specimen')
    plot(1:tmEnd,statsTot(:,2));
    xlabel('Time stamp');
    ylabel('pixel intensity (0-1)');
    figure
    hold on
    title('Total volume affected');
    plot(1:tmEnd,statsTot(:,4));
    xlabel('Time stamp');
    ylabel('microns^3');
else
    while(child)
        statsArray = [statsArray; clInfo(i,10) shapeInfo(i,1:3) shapeInfo(i,8) shapeInfo(i,9)]; %Store the roi statistics
        
        i = PC(i,1); %Get the index of the next time stamp
        if(i==0)
            child=0;
        end
    end
    figure(1)
    hold on
    title(['Average pixel intensity for ROI ' num2str(item)])
    plot(statsArray(:,1),statsArray(:,5));
    xlabel('Time stamp');
    ylabel('pixel intensity (0-1)');
%     figure
%     hold on
%     title(['Total volume affected by ROI ' num2str(item)]);
%     plot(statsArray(:,1),statsArray(:,6));
%     xlabel('Time stamp');
%     ylabel('microns^3');
%     figure
%     hold on
%     title(['Variance spread in 3D for ROI ' num2str(item)]);
%     plot(statsArray(:,1),statsArray(:,2));
%     plot(statsArray(:,1),statsArray(:,3));
%     plot(statsArray(:,1),statsArray(:,4));
%     xlabel('Time stamp');
%     ylabel('Varience');
%     legend('Var X','Var Y', 'Var X');
end

end

