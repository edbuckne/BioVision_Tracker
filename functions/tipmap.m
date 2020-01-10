function [imtip] = tipmap(spm, t)
spmdir = ['SPM' num2str(spm, '%.2u')];
mlfile = [spmdir '/MIDLINE/ml' num2str(t, '%.4u') '.mat'];

if exist(mlfile, 'file')
    load(mlfile, 'S');
else
    error('Must have created a mask for this to work. Try running BVTreconstruct or BVTreconstructunet');
end
if ~exist([spmdir '/tipTrack.mat'], 'file')  % Get the location to measure from
    yS = length(S);
else
    load([spmdir '/tipTrack.mat'], 'tipLoc');
    yS = tipLoc;
end

imtip = createtipmap(spm, t, S, yS(2));
end

