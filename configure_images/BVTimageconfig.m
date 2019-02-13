function BVTimageconfig( )
%Highest level of the overall framework of the pipeline.  This function
%looks for all tif files in the current working directory.  Based on the
%inputs of the user and the information in the configuration fule, the tif
%images are configured for the analysis pipeline. NOTE: BVTconfig must be
%run before this function is called.
% load('data_config');

spm = input('What is the specimen number? ');
CM = input('Which camera do you want to save? '); %Inputs from user
V = input('Which view does this image describe? ');
str = input('What text should each image contain ("-a" all images)? ', 's');
if(strcmp(str,'-a'))
    filelist = dir('*.tif'); %find all files with a '.tif' extension
else
    filelist = dir(['*' str '*']);
end
fileN = length(filelist); %Number of images found in the directory
spmDirName = num2str(['SPM' num2str(spm,'%.2u')]); %Directory name for the specimen file


if(exist(spmDirName)==0) %Make the directory if it doesn't exist
    mkdir(spmDirName)
end

i = 1;
while i<=fileN
    disp(['Saving image ' num2str(i) ' of ' num2str(fileN)]);
    timeDir = ['TM' num2str(i,'%.4u')]; %Make the time directory
    mkdir([spmDirName '/' timeDir]);
    
    fileoi = filelist(i); %Get the name of the next image
    %     Iinfo = imfinfo(fileoi.name); %Get the image info
    %     S = [Iinfo(1).Height Iinfo(1).Width length(Iinfo)]; %Get the dimensions of the image
    %
    %     I = zeros(S); %Load the image in RAM
    %     for z=1:S(3)
    %         I(:,:,z)=im2double(imread(fileoi.name,z));
    %         imwrite(I(:,:,z),[spmDirName '/' timeDir '/' timeDir '_CM' num2str(CM) '_v' num2str(V) '.tif'],'writemode','append');
    %     end
    try
        movefile(fileoi.name,[spmDirName '/' timeDir '/' timeDir '_CM' num2str(CM) '_v' num2str(V) '.tif']);
    catch
        continue;
    end
    i = i+1;
end
disp('Image file configuration complete')
end

