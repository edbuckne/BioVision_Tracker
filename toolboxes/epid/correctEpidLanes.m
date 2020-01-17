function correctEpidLanes(spmList, tMatrix)
% correctEpidLanes(spmList, tMatrix) allows the user to correct any error
% the EPID toolbox made in deriving the epidermal cell files. This function
% will show the image it analyzed while overlaying epidermal cell files
% (red) and non-epidermal cell files (blue). Each file will be given a
% number. The user will type the number of an epidermal file followed by
% enter until the user types 0 and enter, then the function will exit.
% Input:
%   spmList (int vector) - vector of spm to correct
%   tMatrix (int cell) - cell of vectors of time stamps to evaluate. Each
%   cell must correspond with the spmList.

load('./data_config');

for i = 1:length(spmList)
    spm = spmList(i); % Get the specimen number
    spmdir = ['SPM' num2str(spm, '%.2u')];
    
    if exist('tMatrix', 'var') % Create a range of time stamps to correct
        tRange = tMatrix{i};
    else
        findspm = tSpm(:, 1)==spm;
        tRange = tSpm(findspm, 2):tSpm(findspm, 3);
    end
    
    for t = tRange
        tloadsave = [spmdir '/EPID/lanes' num2str(t, '%.4u')];
        load(tloadsave); % Load the lanes data
        
        [~, ~, f] = showEpidLanes(spm, t, true); % print the data on the image
        hold on
        for j = 1:length(allLanes) % Print the numbers for each lane
            [~, topid] = min(allLanes{j}(:, 2)); 
            text(allLanes{j}(topid, 1), allLanes{j}(topid, 2), num2str(j), 'FontSize', 12, 'Color', 'r');
        end
        
        epidLanes = cell(0); % Holds the corrected data for the epidermal cell files
        loop = true; % Loop through gathering information from the user
        while loop
            optin = input('Which are the epidermal cell files (press 0 and enter to save and exit)? ');
            if optin==0
                loop = false;
            else
                try
                    epidLanes{end+1} = allLanes{optin}; % Store the selected data 
                catch
                    warning('That was not an option, try again');
                end
            end
        end
        
        close(f);
        save(tloadsave, 'imz', 'allLanes', 'epidLanes', 'angl');
    end
end
end

