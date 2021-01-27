function printPoints()
% printPoints prints out the results of from BVTseg3d.m in the folder BVT/Points.

load('./data_config'); 
dirpath = './BVT/Points';

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
    [clInfo, ta] = loadclInfo(spm);
    for t = tSpm(i, 2):tSpm(i, 3)
        [~, f] = showMaxProj(spm, t, 1, true, true);
        hold on
        scatter(clInfo(ta(t, 1):ta(t, 2), 1), clInfo(ta(t, 1):ta(t, 2), 2), '.g');
        
        saveas(f, [dirpath '/SPM' num2str(spm, '%.2u') 'tm' num2str(t, '%.4u') '.jpg']);
        pause(0.5);
        close(f);
    end
end
end

