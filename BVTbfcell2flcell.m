function BVTbfcell2flcell(varargin)
% BVTbfcell2flcell(varargin) is a function at the highest level of the
% BVT software. This function takes 3D images of in-vitro cells from a
% brightfield channel and filters these images to make the cells have
% higher intensities than background. Once this is ran, the cell
% segmentation method can be used.
defaultSPMList = 'all';
defaultFilterValue = 3;
defaultBFChannel = 2;
defaultFluorChannel = 1;

p = inputParser();
addParameter(p, 'SPMList', defaultSPMList);  % The list of the specimen to be evaluated
addParameter(p, 'FilterValue', defaultFilterValue); % The smoothing value used to filter the images
addParameter(p, 'BFChannel', defaultBFChannel); % The channel number that holds the brightfield image
addParameter(p, 'FluorChannel', defaultFluorChannel); % The channel number that holds the new "fluorescent" image

parse(p, varargin{:});

load('./data_config.mat');

if ischar(p.Results.SPMList) % Determine if all specimen, or just 1
    if strcmp(p.Results.SPMList, 'all')
        spmlist = tSpm(:, 1)';
    else
        error(['I''m not sure what you mean by ' p.Results.SPM ', this should be ''all'' or a number']);
    end
elseif isnumeric(p.Results.SPMList)
    spmlist = round(p.Results.SPMList);
else
    error('Check your SPMList variable. It should be ''all'' or a number');
end

disp('Creating Contrast Images');
for spm = spmlist % Go through each specimen in the list
    disp(['SPM' num2str(spm, '%.2u')]);
    tList = tSpm(tSpm(:, 1)==spm, 2):tSpm(tSpm(:, 1)==spm, 3); % List of time stamps to evaluate
    for t = tList
        Iin = microImInputRaw(spm, t, p.Results.BFChannel, 1); % Load the image
        
        Ifilt = Iin; % Filter the image
        for z = 1:size(Iin, 3)
            Ifilt(:, :, z) = imgaussfilt(Iin(:, :, z), p.Results.FilterValue);
        end
        
        Igrad2 = Ifilt; % First gradient
        for z = 1:size(Iin, 3)
            Igrad2(:, :, z) = imgradient(Ifilt(:, :, z));
        end
        
        Igrad22 = Igrad2; % Second gradient
        for z = 1:size(Iin, 3)
            Igrad22(:, :, z) = imgradient(Igrad2(:, :, z));
        end
        
        Igrad222 = spreadPixelRange(Igrad2)+spreadPixelRange(Igrad22); % Combine gradient info
        
        Igradfilt = Igrad222; % Filter this final image
        for z = 1:size(Iin, 3)
            Igradfilt(:, :, z) = imgaussfilt(Igrad222(:, :, z), p.Results.FilterValue);
        end
        
        z = 1; % Write these images to a file
        while(z<=size(Iin, 3))
            try
                imwrite(Igradfilt(:, :, z), ['tmp' num2str(t, '%.4u') '.tif'], 'writemode', 'append');
                z = z+1;
            catch
                continue;
            end
        end
    end
    BVTimageconfig(spm, p.Results.FluorChannel, 1, 'tmp');
end
end

