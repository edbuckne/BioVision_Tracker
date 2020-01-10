function BVTimageconfig( spm, CM, V, str )
%Highest level of the overall framework of the pipeline.  This function
%looks for all tif files in the current working directory.  Based on the
%inputs of the user and the information in the configuration fule, the tif
%images are configured for the analysis pipeline. NOTE: BVTconfig must be
%run before this function is called.
% load('data_config');

if ~exist('spm', 'var')
    spm = input('What is the specimen number? ');
end
if ~exist('CM', 'var')
    CM = input('Which camera do you want to save? '); %Inputs from user
end
if ~exist('V', 'var')
    V = input('Which view does this image describe? ');
end
if ~exist('V', 'var')
    str = input('What text should each image contain ("-a" all images)? ', 's');
end
if(strcmp(str,'-a'))
    filelist = dir('*.tif'); %find all files with a '.tif' extension
else
    filelist = dir(['*' str '*']);
end
fileN = length(filelist); %Number of images found in the directory
spmDirName = num2str(['SPM' num2str(spm,'%.2u')]); %Directory name for the specimen file


if(exist(spmDirName)==0) %Make the specimen directory if it doesn't exist
    mkdir(spmDirName)
end

i = 1;
while i<=fileN
    disp(['Saving image ' num2str(i) ' of ' num2str(fileN)]);
    timeDir = ['TM' num2str(i,'%.4u')]; %Make the time directory if it doesn't exist
    if ~exist([spmDirName '/' timeDir], 'dir')
        mkdir([spmDirName '/' timeDir]);
    end
    
    fileoi = filelist(i); %Get the name of the next image
    Iinfo = imfinfo(fileoi.name); %Get the image info
    S = [Iinfo(1).Height Iinfo(1).Width length(Iinfo)]; %Get the dimensions of the image
    
    if S(3)==1 % If this is only a 2D image, make it 3D
        I = im2double(imread(fileoi.name)); % Load file into RAM
        if length(size(I))==3 % If it is an rgb image, make it a grayscale
            I = rgb2gray(I);
        end
        I = cat(3, 0.9.*I, I, 0.9.*I); % Create a 3 z-stack image with outer stacks at lower intensities
        z = 1; % Write image file
        while z<=3
            try
                imwrite(im2uint16(I(:,:,z)),[spmDirName '/' timeDir '/' timeDir '_CM' num2str(CM) '_v' num2str(V) '.tif'],'writemode','append');
                z = z + 1;
            catch
                continue;
            end
        end
        delete(fileoi.name); % Delete the file once done with it
    else % If it is already a 3D image, just move it with its new name
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
    end
    i = i+1;
end
disp('Image file configuration complete')
end

