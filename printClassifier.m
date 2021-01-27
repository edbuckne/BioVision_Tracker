function printClassifier(classifiername, varargin)
% printClassifier(classifiername, varargin) prints the maximum projection and
% classified image of each specimen in BVT/<classifiername>.
defaultCM = 1;
defaultSPMList = 'all';

p = inputParser();
addParameter(p, 'CM', defaultCM);  % The camera to use
addParameter(p, 'SPMList', defaultSPMList); % Holds the list of specimen to print

parse(p, varargin{:});

load('./data_config'); % Load the configuration file

if ischar(p.Results.SPMList) % Determine if all specimen, or just 1
    if strcmp(p.Results.SPMList, 'all')
        spmlist = tSpm(:, 1)';
    else
        error(['I''m not sure what you mean by ' p.Results.SPMList ', this should be ''all'' or a number']);
    end
elseif isnumeric(p.Results.SPMList)
    spmlist = round(p.Results.SPMList);
else
    error('Check your SPM variable. It should be ''all'' or a number');
end

load([classifiername '/classifier.mat']);
dirpath = ['./BVT/' classifiername];

if ~exist('./BVT', 'dir')
    mkdir('BVT');
end
if exist(dirpath, 'dir') % Make the directory if it doesn't exist
    d = dir(dirpath);
    for i = 3:length(d)
        delete(d(i).name);
    end
else
    mkdir(dirpath);
end

for spm = spmlist
    tList = tSpm(tSpm(:, 1)==spm, 2):tSpm(tSpm(:, 1)==spm, 3); % List of timestamps for this specimen
    for t = tList
        savename = ['SPM' num2str(spm, '%.2u') 'TM' num2str(t, '%.4u')]; 
        disp(savename);
        imaxproj = showMaxProj(spm, t, p.Results.CM, true, false); % Grab the maximum projection
        Iin = microImInputRaw(spm, t, p.Results.CM, 1);
        for z = 1:size(Iin, 3)
            Iin(:, :, z) = imgaussfilt(Iin(:, :, z), classObj.Sigma);
        end
        iclass = classifyImage(classObj, Iin); % Classify the 3D Image and get max proj
        iclassmax = max(iclass, [], 3);
        
        imwrite([imaxproj, iclassmax], [dirpath '/' savename '.jpg']);
    end
end
end

