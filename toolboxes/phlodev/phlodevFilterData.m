function phlodevFilterData(spm, modelName, tVec)
% phlodevFilterData is the highest level of function calling in the phlodev
% toolbox. The user must specify the specimen to be evaluated, the name of
% the model to be used, and the time stamps to evaluate. If no time stamps
% are specified, all time stamps will be evaluated. This function filters
% out the data that was not detected as phloem positive.

phloemIndices = [];  % Holds all of the collected indices that are phloem positive

if ~exist('phlodev', 'dir')  % Create needed directories if they do not exist
    mkdir('phlodev')
end
if ~exist('phlodev/filterdata', 'dir')
    mkdir('phlodev/filterdata')
end
dirName = ['phlodev/filterdata/SPM' num2str(spm, '%.2u')];
if ~exist(dirName, 'dir')
    mkdir(dirName);
end

load('data_config.mat');  % Load the configuration data

spmDirName = ['SPM' num2str(spm, '%.2u')];
copyfile([spmDirName '/cell_location_information.mat'], [dirName '/cell_location_information.mat']);
copyfile([spmDirName '/cylCoord.mat'], [dirName '/cylCoord.mat']);
copyfile([spmDirName '/shape_info.mat'], [dirName '/shape_info.mat']);

if ~exist('tVec', 'var')  % Use all time stamps if the user does not specify
    indexSpmLogic = tSpm(:, 1)==spm;
    tVec = tSpm(indexSpmLogic, 2):tSpm(indexSpmLogic, 3);
end

for t = tVec
    [phloemT, ~] = phloemDetectedIndices(spm, t, modelName);  % Detect the phloem ROI's
    phloemIndices = [phloemIndices; phloemT];
end

load([spmDirName '/cell_location_information.mat']);  % Load the old data
load([spmDirName '/cylCoord.mat']);
load([spmDirName '/shape_info.mat']);

clInfo = clInfo(phloemIndices, :);  % Update the data to the new values
cylCoord = cylCoord(phloemIndices, :);
shapeInfo = shapeInfo(phloemIndices, :);

timeArray = updatetimeArray(clInfo);
save([spmDirName '/cell_location_information.mat'], 'clInfo', 'timeArray');  % Save the new data
save([spmDirName '/cylCoord.mat'], 'cylCoord');
save([spmDirName '/shape_info.mat'], 'shapeInfo', 'statsTot');
end

