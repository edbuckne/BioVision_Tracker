function EPIDshowSeg(spm, t)

spmDir = ['SPM' num2str(spm, '%.2u')];
tmStr = num2str(t, '%.4u');
load([spmDir '/EPID/ep' tmStr]);
load([spmDir '/MIDLINE/ml' tmStr]);

epidplotclassifiedcells(Iout, 1-imz, P, ones(length(Pepid), 1), true)

end

