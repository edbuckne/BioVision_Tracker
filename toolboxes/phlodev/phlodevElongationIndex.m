function phlodevElongationIndex( spm )
% phlodevElongationIndex.m calculates all elongation index measurements for
% the specimen specified by spm and saves it into the specimen directory
% under the file elongationIndex.mat in the variable ei.
% Inputs:
%   spm (int): The specimen number id
% Outputs:
%   ei (vec double): Elongation index for each region detected in clInfo

load('data_config'); % Load the configuration data

spmDir = ['SPM' num2str(spm, '%.2u')]; % Initialize variables based on already known information
[clInfo, timeArray] = loadclInfo(spm);
ei = zeros(size(clInfo, 1), 1);

spmIndex = tSpm(:, 1) == spm; % Get the range of time stamps for this specimen
tRange = tSpm(spmIndex, 2):tSpm(spmIndex, 3);

for t = tRange  % Go through each time stamp in the experiment
    I = microImInputRaw(spm, t, 1, 1);  % load the 3d fluorescence image into the I variable
    disp(['Calculating elongation index for time stamp ' num2str(t)]);
    for i = timeArray(t, 1):timeArray(t, 2)  % Go through each detected region in this time stamp
        try
            ei(i) = elongationIndex(spm, i, I);  % Calculate the elongation index
        catch
            ei(i) = 1;
        end
    end
end

save([spmDir '/elongationIndex'], 'ei');
end

