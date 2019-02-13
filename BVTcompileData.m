function [C] = BVTcompileData( varargin )
% BVTcompileData.m collects all data from the pipeline and compiles it to a
% single variable holding an array of cells (C). The input could be the
% name the user wants to name the saved .mat file.  If no value is used a
% name is chosen at random.
%
% C: Column 1: clInfo
%           2: timearray
%           3: shapeInfo
%           4: statsTot
%           5: zStacks
%           6: delSet
%           7: PC
%           8: cylCoord

load('data_config')
S_N = size(tSpm, 1); % Number of specimen in the home folder
C = cell(S_N, 8);
matNames = {'cell_location_information.mat'; ...
            'shape_info.mat'; ...
            'zStacks.mat'; ...
            'delta_set.mat'; ...
            'PC_Relationships.mat'; ...
            'cylCoord.mat'};
            
            
for ss = 1:S_N
    spm = tSpm(ss, 1); % Get the specimen number
    spm_str = ['SPM' num2str(spm, '%.2u')]; % String of specimen directory
    cd(spm_str)
    
    if exist(matNames{1})
        load(matNames{1});
        C{ss, 1} = clInfo;
        C{ss, 2} = timeArray;
    end
    if exist(matNames{2})
        load(matNames{2})
        C{ss, 3} = shapeInfo;
        C{ss, 4} = statsTot;
    end
    if exist(matNames{3})
        load(matNames{3})
        C{ss, 5} = zStacks;
    end
    if exist(matNames{4})
        load(matNames{4})
        C{ss, 6} = delSet;
    end
    if exist(matNames{5})
        load(matNames{5})
        C{ss, 7} = PC;
    end
    if exist(matNames{6})
        load(matNames{6})
        C{ss, 8} = cylCoord;
    end
    cd ..
end

if ~isempty(varargin)
    save(varargin{1}, 'C');
else
    save_name = round(rand(1).*4000);
    save(num2str(save_name), 'C');
end

end

