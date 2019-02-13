function unpackCZI( outPath )
% unpackCZI.m prompts the user to point to CZI files to be unpacked into
% .tiff images. The outPath input variable should be a string of a path to
% where the user desires the images to go. The function uses the
% bio-formats library to read CZI files and their metadata.

disp('Choose a list of CZI files to import'); % User picks files to import
[file, path] = uigetfile('*.czi', 'MultiSelect', 'on'); 
Nfiles = length(file);

for i = 1:Nfiles
    disp(['Opening file ' num2str(i) ' of ' num2str(Nfiles)]);
%     cziIn = bfopen([path file{i}]); % Open files in order of file location
    r = bfGetReader([path file{i}]);
end




end

