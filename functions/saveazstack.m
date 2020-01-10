function saveazstack(SPM, t, cm, name)
% saveazstack.m takes in the specimen, time stamp, camera number, and a
% save name and will prompt the user to pick a z stack that will be saved
% as a double matrix in a .mat file with the name specified by the variable
% name.

I = microImInputRaw(SPM, t, cm, 1);  % Load the image

f = figure;
imshow3D(I);

z = input('Pick a z-stack to save: ');

close(f);

imz = I(:, :, z);

save(['SPM' num2str(SPM, '%.2u') '/' name], 'imz', 'z');

end

