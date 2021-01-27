function showClassifier( spm, t, dirName )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if ~exist('dirName', 'var')
    dirName = input('Input the name of classifier: ', 's');
end
try
    load(['./' dirName '/' dirName]);
catch
    load(['./' dirName '/classifier.mat']);
end


I = microImInputRaw(spm, t, 1, 1); % Load the image
Ifilt = I;
% Iclass = I;
inCom = 1;

for z = 1:size(I, 3)
    Ifilt(:, :, z) = imgaussfilt(I(:, :, z), classObj.Sigma); % Filter the images
end

if strcmp(classObj.Type, 'TH')
    while(inCom==1)
        %         for z = 1:size(I, 3)
        %             Iclass(:, :, z) = Ifilt(:, :, z)>TH;
        %         end
        Iclass = classifyImage(classObj, Ifilt);
        Imax = max(Iclass, [], 3);
        
        figure(1)
        hold off
        imshow([spreadPixelRange(max(I, [], 3)) Imax]);
        
        inCom = input('Do you want to adjust the threshold (1-yes, 0-no)? ');
        if(inCom==1)
            disp(['Current threshold is ' num2str(-classObj.Biases)])
            classObj.Biases = -input('What do you want to change the threshold to? ');
            continue;
        elseif ~(inCom==1)&&~(inCom==0)
            warning([num2str(inCom) ' is an invalid input, try again']);
            inCom = 1;
            continue;
        end
        inCom = input('Do you want to adjust the smoothing value (1-yes, 0-no)? ');
        if(inCom==1)
            disp(['Current sigma is ' num2str(classObj.Sigma)])
            classObj.Sigma = input('What do you want to change the sigma to? ');
            for z = 1:size(I, 3)
                Ifilt(:, :, z) = imgaussfilt(I(:, :, z), classObj.Sigma); % Filter the images
            end
        elseif ~(inCom==1)&&~(inCom==0)
            warning([num2str(inCom) ' is an invalid input, try again']);
            inCom = 1;
            continue;
        end
    end
    save(['./' dirName '/classifier'], 'classObj')
    close all
elseif strcmp(classObj.Type, 'SVM-Y')||strcmp(classObj.Type, 'NN') % Support vector machine with respect to Y location
    inCom = 1;
    
    while inCom==1
        Iclass = classifyImage(classObj, Ifilt);
        IclassMax = max(Iclass, [], 3);
        
        imshow([spreadPixelRange(max(I, [], 3)) IclassMax]);
        
        inCom = input('Do you want to adjust the filtering value (1-yes, 0-no)? ');
        if(inCom==1)
            disp(['Current sigma is ' num2str(classObj.Sigma)])
            classObj.Sigma = input('What do you want to change the sigma to? ');
            for z = 1:size(I, 3)
                Ifilt(:, :, z) = imgaussfilt(I(:, :, z), classObj.Sigma); % Filter the images
            end
        end
        close all
    end
    save(['./' dirName '/classifier'], 'classObj')
elseif strcmp(classObj.Type, 'LinearTH') % Linear threshold method with respect to the z stack
    linParam = zeros(2);  % 2x2 matrix that will hold the parameters for setting filtering and threshold with respect to the z-stack
    f = figure;
    imshow3D(Ifilt)
    
    linParam(1, 1) = input('Select the first Z Stack to set a threshold: ');  % z1
    close(f);
    
    loop = true;  % Logical loop holder to stay true as long as the user is adjusting
    
    while loop
        inCom = input('Do you want to adjust the threshold (1-yes, 0-no)? ');
        if inCom == 1
            close all;
            linParam(1, 2) = input('What do you want to change the threshold to? ');
            f = figure;  % Show the user and ask what they think
            imshow([spreadPixelRange(I(:, :, linParam(1, 1))), spreadPixelRange(Ifilt(:, :, linParam(1, 1))), Ifilt(:, :, linParam(1, 1))>linParam(1, 2)])
            continue;
        end
        
        inCom = input('Do you want to adjust the sigma (1-yes, 0-no)? ');
        if inCom == 1
            close all;
            classObj.Sigma = input('What do you want to change the sigma to? ');
            
            for z = 1:size(I, 3)
                Ifilt(:, :, z) = imgaussfilt(I(:, :, z), classObj.Sigma); % Filter the images
            end
            
            f = figure;  % Show the user and ask what they think
            imshow([spreadPixelRange(I(:, :, linParam(1, 1))), spreadPixelRange(Ifilt(:, :, linParam(1, 1))), Ifilt(:, :, linParam(1, 1))>linParam(1, 2)])
            continue;
        else
            loop = false;
        end
    end
    
    f = figure;
    imshow3D(spreadPixelRange(I))
    
    linParam(2, 1) = input('Select the second Z Stack to set a threshold: ');  % z2
    close(f);
    
    loop = true;  % Logical loop holder to stay true as long as the user is adjusting
    
    while loop
        inCom = input('Do you want to adjust the threshold (1-yes, 0-no)? ');
        if inCom == 1
            close all;
            linParam(2, 2) = input('What do you want to change the threshold to? ');
            f = figure;  % Show the user and ask what they think
            imshow([spreadPixelRange(I(:, :, linParam(2, 1))), spreadPixelRange(Ifilt(:, :, linParam(2, 1))), Ifilt(:, :, linParam(2, 1))>linParam(2, 2)])
            continue;
        end
        
        inCom = input('Do you want to adjust the sigma (1-yes, 0-no)? ');
        if inCom == 1
            close all;
            classObj.Sigma = input('What do you want to change the sigma to? ');
            
            for z = 1:size(I, 3)
                Ifilt(:, :, z) = imgaussfilt(I(:, :, z), classObj.Sigma); % Filter the images
            end
            
            f = figure;  % Show the user and ask what they think
            imshow([spreadPixelRange(I(:, :, linParam(2, 1))), spreadPixelRange(Ifilt(:, :, linParam(2, 1))), Ifilt(:, :, linParam(2, 1))>linParam(2, 2)])
            continue;
        else
            loop = false;
        end
    end
    
    classObj.Weights = inv([linParam(1, 1), 1; linParam(2, 1), 1])*linParam(:, 2);
    classObj.LinCap = [min(linParam(:, 1)), max(linParam(:, 1))];
    
    save(['./' dirName '/classifier'], 'classObj')
elseif strcmp(classObj.Type, 'AD-TH') % Adaptive threshold and global threshold
%     classObj.adthW = 15;  % Initial values for adaptive thresholding
%     classObj.adthP = 0.5;
%     classObj.Sigma = 2;
%     classObj.Biases = -0.5;
    
    loop = true;
    
    while loop
        close all
        Ithinit = classifyImage(classObj, Ifilt);  % This method can only do 2D images at a time
        
        f = figure;
        imshow([spreadPixelRange(max(I, [], 3)), max(Ithinit, [], 3)]);
        opt1 = input('Which would you rather edit? (0 - None, 1 - [TH]Threshold/Standard Deviation, 2 - [AD]Window/Percentage): ');
        loop2 = true;
        
        if opt1 == 0
            break;
        elseif opt1 == 1
            while loop2
                close all
                figure
                imshow([max(I, [], 3), max(Ifilt, [], 3)>-classObj.Biases]);
                inCom = input('Do you want to adjust the threshold (1-yes, 0-no)? ');
                if(inCom==1)
                    disp(['Current threshold is ' num2str(-classObj.Biases)])
                    classObj.Biases = -input('What do you want to change the threshold to? ');
                    continue;
                end
                inCom = input('Do you want to adjust the filtering value (1-yes, 0-no)? ');
                if(inCom==1)
                    disp(['Current sigma is ' num2str(classObj.Sigma)])
                    classObj.Sigma = input('What do you want to change the sigma to? ');
                    for z = 1:size(I, 3)
                        Ifilt(:, :, z) = imgaussfilt(I(:, :, z), classObj.Sigma); % Filter the images
                    end
                    continue;
                end
                break;
            end
        elseif opt1 == 2
            while loop2
                close all
                figure
                Ithinit = Ifilt;
                for z = 1:size(Ifilt, 3)
                    T = adaptthresh(Ifilt(:, :, z), classObj.adthP, 'NeighborhoodSize', classObj.adthW);
                    Ithinit(:, :, z) = imbinarize(Ifilt(:, :, z),T);
                end
                imshow([max(I, [], 3), max(Ithinit, [], 3)]);
                inCom = input('Do you want to adjust the window shize (1-yes, 0-no)? ');
                if(inCom==1)
                    disp(['Current window size is ' num2str(classObj.adthW)])
                    classObj.adthW = input('What do you want to change the window size to? ');
                    continue;
                end
                inCom = input('Do you want to adjust the percentage value (1-yes, 0-no)? ');
                if(inCom==1)
                    disp(['Current percentage is ' num2str(classObj.adthP)])
                    classObj.adthP = input('What do you want to change the percentage to? ');
                    continue;
                end
                break;
            end
        else
            continue;
        end
    end
    save(['./' dirName '/classifier'], 'classObj')
end

