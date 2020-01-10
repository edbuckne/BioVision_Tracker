function [out, taOut] = loadclInfo(spm)
load(['SPM' num2str(spm, '%.2u') '/cell_location_information.mat']);
out = clInfo;
taOut = timeArray;
end

