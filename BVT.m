function BVT( varargin )

load('data_config.mat')
shift = [100, 1000, 5];

if(size(varargin,2)==0)
    for i = 1:size(tSpm, 1)
        spm = tSpm(i, 1);
        disp(['Running BVT Software for SPM' num2str(spm, '%.2u')])
        
        BVTseg3d(spm)
        BVTmeasure(spm);
        BVTregister(spm, shift);
        BVTtrack(spm);
        BVTreconstruct(spm);
        BVTmap(spm);
    end
else
    spm = varargin{1};
    disp(['Running BVT Software for SPM' num2str(spm, '%.2u')])
    
    BVTseg3d(spm)
    BVTmeasure(spm);
    BVTregister(spm, shift);
    BVTtrack(spm);
    BVTreconstruct(spm);
    BVTmap(spm);
end


end

