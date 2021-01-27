function printSeg( varargin )
% Prints out to a folder (cellSeg) RGB images of cell segmentation from camera 1.
% If an argument is present, segmentation tracking is enabled which means
% each segmented region that is tracked through time will be the same
% color.

load('./data_config.mat');

if~(exist('BVT/cellSeg')) % Create the directory to store the images
    mkdir('BVT/cellSeg');
end
if(size(varargin, 2)>0) % If there is in input, seg tracking has been enabled
    spmI = find(tSpm(:, 1)==varargin{1}); 
    spmN = spmI;
    load(['SPM' num2str(tSpm(spmI, 1), '%.2u') '/cell_location_information.mat']);
    load(['SPM' num2str(tSpm(spmI, 1), '%.2u') '/PC_Relationships.mat']);
    load(['SPM' num2str(tSpm(spmI, 1), '%.2u') '/delta_set.mat']);
    cc = zeros(size(clInfo, 1), 3);
    for i = 1:size(clInfo, 1)
        if (PC(i, 2)==0)
            cc(i, :) = rand(1, 3);
        else
            cc(i, :) = cc(PC(i, 2), :);
        end
    end
else
    spmN = 1:size(tSpm, 1); % Go through each specimen at each time point and print it
end

    
for i = spmN
    Itmp = microImInputRaw(tSpm(i, 1), 1, 1, 1);
    load(['SPM' num2str(tSpm(i, 1), '%.2u') '/cell_location_information.mat']);
    S = size(Itmp);
%     clear Itmp;
%     Imovie = zeros(S(1), 2*S(2), 3, tSpm(i, 3));
    Ishow3D = zeros(S(1), 2*S(2), tSpm(i, 3), 3);
%     Imovie = zeros(S(1), 2*S(2), 3, 4);
    f2 = waitbar(0, 'Printing Segmentation Results');
    for j = 1:tSpm(i, 3)
        prog = j/tSpm(i, 3);
        waitbar(prog, f2, ['Printing Segmentation Results ' num2str(j) ' of ' num2str(tSpm(i, 3))]);
        if(timeArray(j, 1)==0)
            continue;
        end
%         disp(['Printing Segmentation Results for SPM:' num2str(tSpm(i, 1)), ' Time:' num2str(j)]);
        if(size(varargin, 2)>0)
            if(j==1)
                del = [0, 0];
            else
                del = sum(delSet(1:j-1, 1:2), 1);
            end
            [f, Irgb] = showSeg(tSpm(i, 1), j, 'randTrack', cc, -del);
        else
            [f, Irgb] = showSeg(tSpm(i, 1), j, 'rand');
        end
%         close(f)
%         Imovie(:, :, :, j) = Irgb;
        Ishow3D(:, :, j, 1) = [spreadPixelRange(max(Itmp, [], 3)), Irgb(:, :, 1)];
        Ishow3D(:, :, j, 2) = [spreadPixelRange(max(Itmp, [], 3)), Irgb(:, :, 2)];
        Ishow3D(:, :, j, 3) = [spreadPixelRange(max(Itmp, [], 3)), Irgb(:, :, 3)];
        imwrite(squeeze(Ishow3D(:, :, j, :)), ['BVT/cellSeg/SPM' num2str(tSpm(i, 1), '%.2u') '_TM' num2str(j, '%.4u') '.png']);
        
        close all
    end
    close(f2)
%     v = VideoWriter(['cellSeg/SPM' num2str(tSpm(i, 1), '%.2u') '_SEG_TRACK.avi']);
%     v.FrameRate = 2;
%     open(v)
% %     mov = immovie(Imovie);
%     writeVideo(v, Imovie);
%     save(['cellSeg/SPM' num2str(tSpm(i, 1), '%.2u') '_SEG_TRACK'], 'Ishow3D', '-v7.3');
end
% close(f2)
% close all
% figure
% imshow3D(Ishow3D)

end

