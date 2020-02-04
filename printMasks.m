function printMasks()
% printMasks prints out the results of from BVTreconstruct.m and 
% BVTreconstructunet.m in the folder Masks.

load('./data_config'); 
dirpath = './BVT/Masks';

if ~exist('./BVT', 'dir')
    mkdir('BVT');
end
if ~exist(dirpath, 'dir') % Make the directory if it doesn't exist
    mkdir(dirpath);
end

d = dir(dirpath); % Get all of the files in this directory and delete them
for i = 3:length(d)
    delete([dirpath '/' d(i).name]);
end

spmlist = tSpm(:, 1)';
i = 1;
for spm = spmlist
    for t = tSpm(i, 2):tSpm(i, 3)
        im = showMask(spm, t, false);
        imax = showMaxProj(spm, t, 2, false, false);
        
        imwrite([imax, im], [dirpath '/SPM' num2str(spm, '%.2u') 'tm' num2str(t, '%.4u') '.jpg']);
    end
    i = i+1;
end
end

