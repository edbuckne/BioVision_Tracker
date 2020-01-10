function BVTimageunconfig( varargin )
% BVTimageunconfig.m - This function will undo what BVTimageconfig does by
% going into the organized folders of a specimen indicated by the user and
% print out all contents as T0001_C01_V01.tif, T0001_C02_V01.tif, T0002_C01_V01.tif,
% .... Where is goes time_camera_view.tif.
% Inputs:
%   varargin{1}: Specimen to unpack files from
% run('set_path/setPath.m');
load('data_config.mat') % Must have a data_config file for this to work

if ~isempty(varargin) % If we do have an argument come into the function
    spm = varargin{1}; % Assign the first item to spm
else
    spm = input('Which specimen do you want to unpack? '); % Otherwise prompt the user
end

sI = find(tSpm(:, 1)==spm); % Find the index of the specimen in tSpm

for t = tSpm(sI, 2):tSpm(sI, 3) % Go through all time stamps of that specimen
    dirName = ['SPM' num2str(spm, '%.2u') '/TM' num2str(t, '%.4u')];
    d = dir(dirName); % Find contents in that folder
    dLen = length(d);
    
    for di = 3:dLen % Start at 3 to avoid '.' and '..'
        iName = d(di).name; % Get the image data from the name
        tm = str2double(iName(3:6));
        cm = str2double(iName(10));
        v = str2double(iName(13));
        
        movefile([dirName '/' iName], ['T' num2str(tm, '%.4u') '_C' num2str(cm, '%.2u') '_V' num2str(v, '%.2u') '.tif']); % Move file to working directory
    end
    rmdir(dirName); % Remove directory when finished
end
rmdir(['SPM' num2str(spm, '%.2u')]);

end

