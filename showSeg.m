function [f, Irgb2] = showSeg( spm, t, varargin )
% Shows the segmented gfp regions in different fashions.

load('data_config.mat')
cd(['SPM' num2str(spm, '%.2u')]);
load('cell_location_information.mat');

if(size(varargin,2)==0)
    mode = 'default';
else
    mode = varargin{1};
end

Iname = ['3D_SEG/SPM' num2str(spm, '%.2u') '/TM' num2str(t, '%.4u') '/SEG_IM.tif']; % Path to segmentation image
z = imfinfo(Iname); % Get information about the image
I = microImInputRaw(spm, t, 1, 1); % Obtain the raw 3D image
Immpp = max(I, [], 3); % Get a maximum projection of the image
Iseg = zeros(z(1).Height, z(1).Width, length(z)); % Segmentation image
for zz = 1:size(Iseg, 3)
    Iseg(:, :, zz) = im2double(imread(Iname, zz));
end

switch(mode)
    case 'rand3'
        i = 1;
        randCol = rand(timeArray(t, 2)-timeArray(t, 1)+50, 3);
        IrandSeg = zeros(size(Iseg, 1), size(Iseg, 2), size(Iseg, 3), 3);
        f = waitbar(0, 'Collecting segmentation info ...');
        rowS = size(Iseg, 1);
        for row = 1:rowS
            waitbar(row/rowS, f, ['Collecting segmentation info ... ' num2str(100*row/rowS, '%.2f'), '%']);
            for col = 1:size(Iseg, 2)
                for z = 1:size(Iseg, 3)
                    if(Iseg(row, col, z)>0)
                        val = Iseg(row, col, z);
                        IrandSeg(:, :, :, 1) = IrandSeg(:, :, :, 1)+double(Iseg==val).*randCol(i, 1);
                        IrandSeg(:, :, :, 2) = IrandSeg(:, :, :, 2)+double(Iseg==val).*randCol(i, 2);
                        IrandSeg(:, :, :, 3) = IrandSeg(:, :, :, 3)+double(Iseg==val).*randCol(i, 3);
                        Iseg = Iseg-double(Iseg==val).*val;
                        i = i+1;
                    end
                end
            end
        end
        
        Immpp = spreadPixelRange(I);
        
        figure
        imshow3D([cat(4, Immpp, Immpp, Immpp), IrandSeg]);
        close(f)
    case 'rand'
        i = 1;
        if(size(varargin,2)==2)
            randCol = varargin{2};
        else
            randCol = rand(timeArray(t, 2)-timeArray(t, 1)+50, 3);
        end
        randCol = rand(timeArray(t, 2)-timeArray(t, 1)+2000, 3);
        Imp = max(Iseg, [], 3);
        Imp2 = Immpp;
        Irgb = zeros(size(Imp, 1), size(Imp, 2), 3);
        for row = 1:size(Imp, 1)
            for col = 1:size(Imp, 2)
                if(Imp(row, col)>0)
                    val = Imp(row, col);
                    Irgb(:, :, 1) = Irgb(:, :, 1)+double(Imp==val).*randCol(i, 1);
                    Irgb(:, :, 2) = Irgb(:, :, 2)+double(Imp==val).*randCol(i, 2);
                    Irgb(:, :, 3) = Irgb(:, :, 3)+double(Imp==val).*randCol(i, 3);
                    Imp = Imp-double(Imp==val).*val;
                    i = i+1;
                end
            end
        end
        Immpp = spreadPixelRange(Immpp);
%         ImmppC = double(classifyImage(classObj, imgaussfilt(Imp2, 0.5)));
%         
%         Irgb(:, :, 1) = Irgb(:, :, 1).*ImmppC;
%         Irgb(:, :, 2) = Irgb(:, :, 2).*ImmppC;
%         Irgb(:, :, 3) = Irgb(:, :, 3).*ImmppC;
        
        f = figure;
        Irgb2 = Irgb;
        imshow([cat(3, Immpp, Immpp, Immpp), Irgb]);
    case 'randTrack'
        if(size(varargin,2)>=2)
            randCol = varargin{2};
        else
            randCol = rand(timeArray(t, 2)-timeArray(t, 1)+50, 3);
        end
        Imp = max(Iseg, [], 3);
        sI = size(Imp);
        rowCenter = round(sI(1)/2); colCenter = round(sI(2)/2);
        rowCOM = mean(clInfo(timeArray(t, 1):timeArray(t, 2), 2));
        colCOM = mean(clInfo(timeArray(t, 1):timeArray(t, 2), 1));
        rowDel = rowCenter-rowCOM;
        colDel = colCenter-colCOM;
        Imp2 = Immpp;
        Irgb = zeros(size(Imp, 1), size(Imp, 2), 3);
        for i = timeArray(t, 1):timeArray(t, 2)
            row = clInfo(i, 2);
            col = clInfo(i, 1);
            z = clInfo(i, 3);
            if row==0
                continue;
            end
            val = Iseg(row, col, z);
            if val==0
                continue;
            end
            Irgb(:, :, 1) = Irgb(:, :, 1)+double(Imp==val).*randCol(i, 1);
            Irgb(:, :, 2) = Irgb(:, :, 2)+double(Imp==val).*randCol(i, 2);
            Irgb(:, :, 3) = Irgb(:, :, 3)+double(Imp==val).*randCol(i, 3);
            Imp = Imp-double(Imp==val).*val;
        end
        if(size(varargin, 2)>=3)
            T = [colDel, rowDel];
        else
            T = [0, 0];
        end
        Immpp = spreadPixelRange(Immpp);
%         ImmppC = double(classifyImage(classObj, imgaussfilt(Imp2, 0.5)));
%         
%         Irgb(:, :, 1) = Irgb(:, :, 1).*ImmppC;
%         Irgb(:, :, 2) = Irgb(:, :, 2).*ImmppC;
%         Irgb(:, :, 3) = Irgb(:, :, 3).*ImmppC;
        
        
        Irgb2 = [cat(3, Immpp, Immpp, Immpp), Irgb];
        f = figure(1);
        imshow(Irgb2);
       
    case 'randInt'
        i = 1;
        randCol = rand(timeArray(t, 2)-timeArray(t, 1)+50, 3);
        Imp = max(Iseg, [], 3);
        Irgb = zeros(size(Imp, 1), size(Imp, 2), 3);
        for row = 1:size(Imp, 1)
            for col = 1:size(Imp, 2)
                if(Imp(row, col)>0)
                    val = Imp(row, col);
                    Irgb(:, :, 1) = Irgb(:, :, 1)+double(Imp==val).*randCol(i, 1);
                    Irgb(:, :, 2) = Irgb(:, :, 2)+double(Imp==val).*randCol(i, 2);
                    Irgb(:, :, 3) = Irgb(:, :, 3)+double(Imp==val).*randCol(i, 3);
                    Imp = Imp-double(Imp==val).*val;
                    i = i+1;
                end
            end
        end
        Immpp = spreadPixelRange(Immpp);
        
        figure
        imshow([cat(3, Immpp, Immpp, Immpp), cat(3, Immpp, Immpp, Immpp).*Irgb./0.5]);
    case 'rand3Model'
        i = 1;
        randCol = rand(timeArray(t, 2)-timeArray(t, 1)+50, 3); % Create an array of random colors
        f = waitbar(0, 'Collecting segmentation info ...');
        rowS = size(Iseg, 1);
        ff = figure;
        for row = 1:rowS
            waitbar(row/rowS, f, ['Collecting segmentation info ... ' num2str(100*row/rowS, '%.2f'), '%']);
            for col = 1:size(Iseg, 2)
                for z = 1:size(Iseg, 3)
                    if(Iseg(row, col, z)>0)
                        val = Iseg(row, col, z);
                        IBW3D = Iseg==val; % Get a logical image showing all voxels of the indicated region
                        
                        eval(['p' num2str(i) '= patch(isosurface(double(IBW3D), 0));']);
                        eval(['p' num2str(i) '.FaceColor = randCol(i, :);']);
                        eval(['p' num2str(i) '.EdgeColor = ''none'';']);
                        ax=gca; ax.SortMethod='childorder';
                        hold on
                        
                        Iseg = Iseg-double(Iseg==val).*val;
                        i = i+1;
                    end
                end
            end
        end
        
        spmdir = ['SPM' num2str(spm, '%.2u')]; % Include a model of the root if it is available
        maskimage = [spmdir '/MIDLINE/mask' num2str(t, '%.4u') '.tif'];
        maskdata = [spmdir '/MIDLINE/ml' num2str(t, '%.4u') '.mat'];
        
        if exist(maskimage, 'file')&&exist(maskdata, 'file') % If the mask has been created, create a model
            showModel(spm, t, ff);
        end
        
        
        close(f)
    case 'default'
        Imp = max(im2uint8(Iseg), [], 3);
        Irgb = im2double(label2rgb(Imp));
        Irgb(:, :, 1) = Irgb(:, :, 1).*Immpp;
        Irgb(:, :, 2) = Irgb(:, :, 2).*Immpp;
        Irgb(:, :, 3) = Irgb(:, :, 3).*Immpp;
        
        figure
        imshow(Irgb./0.01)
    otherwise
        cd ..
        error([mode ' is not an option for this function'])
end

cd ..
end

