function BVTexportDataXLSX(saveName)
% exportDataXLSX.m - Exports all data compiled by the BVT software into a
% single compact excel sheet for each specimen in the current working
% directory.

load('./data_config'); % Load the configuration file

columnNames1 = {'ID', 'SPM', 'X_Center', 'Y_Center', 'Z_Center', 'Xmin', 'Xmax', 'Ymin', ...
    'Ymax', 'Zmin', 'Zmax', 'Time_Stamp', 'Tip_Distance', 'Longitudinal_Center_Distance', ...
    'Child_ID', 'Parent_ID', 'Variance_in_X', 'Variance_in_Y', 'Variance_in_Z', ...
    'Covariance_XY', 'Covariance_XZ', 'Covariance_YZ', 'Voxel_Count', ...
    'Average_Voxel_Intensity', 'Sum_of_Voxel_Intensities', 'Maximum_Voxel_Intensity'};

columnNames2 = {'Time_Stamp', 'SPM', 'ID1', 'ID2', 'Count', 'X_Dimensions', ...
    'Y_Dimensions', 'Number_of_Z_Stacks', 'X_Shift', 'Y_Shift', 'Z_Shift', ...
    'Total_Count', 'Average_Intensity'};

rowNames = {'Mean', 'Variance', 'Sum'};

dataAgg = [];
sheetCount = 1;
for spm = tSpm(:, 1)'
    spmdir = ['SPM' num2str(spm, '%.2u')]; % Name of the specimen directory
    
%     if spm==tSpm(1, 1)
%         writetable(table(), [saveName '.xlsx'], 'Sheet', 'BLANK');
%     end
    
    paths = cell(6, 1); % holds all of the paths to the data from BVT
    paths{1} = [spmdir '/cell_location_information.mat'];
    paths{2} = [spmdir '/cylCoord.mat'];
    paths{3} = [spmdir '/delta_set.mat'];
    paths{4} = [spmdir '/PC_Relationships.mat'];
    paths{5} = [spmdir '/shape_info.mat'];
    paths{6} = [spmdir '/zStacks.mat'];
    
    if exist(paths{1}, 'file') % Configure cell_location_information
        load(paths{1});
        N = size(clInfo, 1);
        Nt = size(timeArray, 1);
        data = ones(N, length(columnNames1)).*-1;
        datat = ones(Nt, length(columnNames2)).*-1;
        data(:, 1) = (1:N)';
        data(:, 2) = ones(N, 1).*spm;
        data(:, 3:12) = clInfo;
        datat(:, 1) = (1:Nt)';
        datat(:, 2) = ones(Nt, 1).*spm;
        datat(:, 3:4) = timeArray;
        datat(:, 5) = (timeArray(:, 2)-timeArray(:, 1))+1;
    else
        error('Must have at least ran BVTseg3d to configure data');
    end

    if exist(paths{2}, 'file') % Cylindrical coordinates
        load(paths{2});
        data(:, 13:14) = cylCoord(:, 1:2);
    end
    
    if exist(paths{4}, 'file') % Parent/child tracking
        load(paths{4});
        data(:, 15:16) = PC;
    end
    
    if exist(paths{5}, 'file')
        load(paths{5});
        data(:, 17:26) = shapeInfo;
        datat(:, 12:13) = statsTot(:, 1:2);
    end   
    
%     com = [];
%     for i = 1:25
%         com = [com, 'data(:, ' num2str(i) '), '];
%     end
    dataTable = array2table(data, 'VariableNames', columnNames1);
    writetable(dataTable, [saveName '.xlsx'], 'Sheet', sheetCount);
        
    if exist(paths{6}, 'file')
        load(paths{6});
        datat(:, 6:8) = zStacks;
    end
    
    if exist(paths{3}, 'file')
        load(paths{3});
        datat(:, 9:11) = [0, 0, 0; delSet(:, 1:3)];
    end
    
    datatTable = array2table(datat, 'VariableNames', columnNames2);
    writetable(datatTable, [saveName '_t.xlsx'], 'Sheet', sheetCount);
    sheetCount = sheetCount + 1;
end

