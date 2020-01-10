function showEpidCells(spm, t)
% showEpidCells(spm, t) - shows the detected cell walls in the epidermal
% files indicated by the EPID toolbox. Must have called EPIDcell.m before
% calling this function.
spmdir = ['SPM' num2str(spm, '%.2u')]; % Specimen directory
lanefile = ['lanes' num2str(t, '%.4u')]; % Lanes file
cellfile = ['cells' num2str(t, '%.4u')]; % Cells file

load([spmdir '/EPID/' lanefile]); % Load the data in the files
load([spmdir '/EPID/' cellfile]);

f = figure;
imshow(imrotate(imz, angl));
hold on
for k = 1:length(epidLanes)
    scatter(epidLanes{k}(cwidx{k}==1, 1), epidLanes{k}(cwidx{k}==1, 2), '.r');
end
end

