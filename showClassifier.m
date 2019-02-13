function showClassifier( spm, t )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
save_NAME = input('Input the name of classifier data: ', 's');
load([save_NAME '/' save_NAME]);

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
        end
        inCom = input('Do you want to adjust the filtering value (1-yes, 0-no)? ');
        if(inCom==1)
            disp(['Current sigma is ' num2str(classObj.Sigma)])
            classObj.Sigma = input('What do you want to change the sigma to? ');
            for z = 1:size(I, 3)
                Ifilt(:, :, z) = imgaussfilt(I(:, :, z), classObj.Sigma); % Filter the images
            end
        end
    end
    save([save_NAME '/' save_NAME], 'classObj')
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
    save([save_NAME '/' save_NAME], 'classObj')
end

end

