function printEpidCells()
% printEpidCells prints out the results of from EPIDcell.m in the folder
% EPID/EpidCells.

load('./data_config'); 
dirpath = 'EPID/EpidCells';

if ~exist(dirpath, 'dir') % Make the directory if it doesn't exist
    mkdir(dirpath);
end

d = dir(dirpath); % Get all of the files in this directory and delete them
for i = 3:length(d)
    delete([dirpath '/' d(i).name]);
end

for spm = tSpm(1, 1):tSpm(end, 1) % Go through all specimen
    for t = tSpm(spm, 2):tSpm(spm, 3) % Go through all the time points for this specimen
        close all
        Ilane = showEpidCells(spm, t); % Collect the image that shows the epidermal cell boundaries
        
        saveas(Ilane, [dirpath '/SPM' num2str(spm, '%.2u') 'T' num2str(t, '%.4u') '.jpg']); % Write the file
    end
end
end

