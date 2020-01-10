function I3dSeg = load3DSeg(spm, t)
I3dSeg = imread3D(['SPM' num2str(spm, '%.2u') '/3D_SEG/SPM' num2str(spm, '%.2u') '/TM' num2str(t, '%.4u') '/SEG_IM.tif']);
end

