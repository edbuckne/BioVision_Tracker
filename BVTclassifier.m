function BVTclassifier( mode, spm, T, cm, add )
% BVTclassifier.m
%
% This function is used to determine the classifier for gene expression
% segmentation. The mode variable determines which classifier will be used for
% segmentation, and the T variable is which time stamp an image will be
% evaluated. 

metName = input('Please name the classifier: ', 's');
if ~exist(metName)
    mkdir(metName)
    dirCon = cell(2, 1);
    dirCon{1} = mode;
else
    load([metName '/dirCon'])
end
classObj = classifier; % Create object
classObj.Type = mode;
classObj.Sigma = 2;
CrandTot = [];
Cval = [];

if ~add
    NN = size(dirCon{2}, 1);
    f = waitbar(0, 'Randomly sampling images');
    disp('Creating training data');
    for i = 1:NN
        waitbar(i/NN, f, ['Randomly sampling images ... ' num2str(100*i/NN, '%.2f'), '%']);
        I = microImInputRaw(dirCon{2}(i, 1), dirCon{2}(i, 2), dirCon{2}(i, 3), 1); % Load the image
        S = size(I);
        try
            Im = im2double(imread([metName '/' num2str(i) '.tif'])); % Take in edited mask
        catch
            continue;
        end
        Imask = Im(:, :, 1)==1; % Partition the image into 2 classes
        Im = max(I, [], 3);
        
        C1 = find(Imask==1); % Find all instances of class 1 and 0
        C2 = find(Imask==0);
        
        RandGen = rand(500, 2); % Randomize the picking of pixels with classes (1000 points)
        Crand = zeros(1000, 2);
        Crand(1:500, 1) = ceil(length(C1).*RandGen(:, 1));
        Crand(1:500, 2) = 1;
        Crand(501:1000, 1) = ceil(length(C2).*RandGen(:, 2));
        Crand(1:500, 1) = C1(Crand(1:500, 1));
        Crand(501:1000, 1) = C2(Crand(501:1000, 1));
        
        Crand2 = zeros(size(Crand, 1), 3);
        Crand2(1:500, 1) = Im(Crand(1:500, 1)); % Crand holds half class 1, half class 2
        Crand2(501:1000, 1) = Im(Crand(501:1000, 1));
        Crand2(:, 2) = Crand(:, 2);
        Crand2(:, 3) = Crand(:, 1);
        
        RandGen = rand(1000, 1); % Randomize the picking of pixels with classes (1000 points
        Crand = zeros(1000, 2);
        Crand(:, 1) = ceil(length(Im(:)).*RandGen);
        Crand(:, 2) = Imask(Crand(:, 1));
        
%         Cval = zeros(size(Crand, 1), 3);
%         Cval(:, 1) = Im(Crand(:, 1));
%         Cval(:, 2) = Crand(:, 2);
%         Cval(:, 3) = Crand(:, 1);
        
        Cval = [Cval; Im(Crand(:, 1)), Crand(:, 2), Crand(:, 1)];
        
        CrandTot = [CrandTot; Crand2];
    end
    
    close(f)
    Crand2 = CrandTot;
    
    switch(mode)
        case 'TH'
            disp('Fitting data to a simple voxel threshold classification model');
            
            classObj.D = 1; % Dimensions of classifier is 1
            classObj.Weights = 1; % Multiply the data by this
            
            maxAcc = 0; maxTH = 0;
            for tt = 0.0001:0.0001:1
                pred = double(Crand2(:, 1)>tt); % Check all data points above threshold
                same = double(pred==Crand2(:, 2));
                acc = sum(same)./1000;
                
                if acc>maxAcc
                    maxAcc = acc;
                    maxTH = tt;
                end
            end
            f = figure;
            h1 = histogram(Crand2(Crand2(:, 2)==0, 1), 'facecolor', 'r', 'BinWidth', 1e-4);
            hold on
            h2 = histogram(Crand2(Crand2(:, 2)==1, 1), 'facecolor', 'g', 'BinWidth', 1e-4);
            line([maxTH, maxTH], f.CurrentAxes.YLim);
            classObj.Biases = -maxTH;
            save([metName '/classifier'], 'classObj');
        case 'TH2' % This is for the case of having stained cell walls
            disp('Fitting data to a simple voxel threshold classification model');
            
            classObj.D = 1; % Dimensions of classifier is 1
            classObj.Weights = 1; % Multiply the data by this
            
            maxAcc = 0; maxTH = 0;
            for tt = 0.0001:0.0001:1
                pred = double(Crand2(:, 1)>tt); % Check all data points above threshold
                same = double(pred==Crand2(:, 2));
                acc = sum(same)./1000;
                
                if acc>maxAcc
                    maxAcc = acc;
                    maxTH = tt;
                end
            end
            classObj.Biases = -maxTH;
            save([metName '/classifier'], 'classObj');
        case 'SVM-Y'
            Iy = zeros(S(1), S(2)); % Iy holds the y position
            for row = 1:S(1)
                Iy(row, :) = ones(1, S(2)).*row;
            end
            Xdata = [Crand2(:, 1) Iy(Crand2(:, 3))];
            Ydata = Crand2(:, 2);
%             Xdata = [Cval(:, 1) Iy(Cval(:, 3))];
%             Ydata = Cval(:, 2);
            
            figure
            Msvm = svmtrain(Xdata, Ydata, 'showplot', 'true');
            W1 = sum(Msvm.Alpha.*((Msvm.SupportVectors(:, 1)+Msvm.ScaleData.shift(1)).*Msvm.ScaleData.scaleFactor(1))); % Transfer information to data space
            W2 = sum(Msvm.Alpha.*((Msvm.SupportVectors(:, 2)+Msvm.ScaleData.shift(2)).*Msvm.ScaleData.scaleFactor(2)));
            
            dataTrans = [(Xdata(:, 1)+Msvm.ScaleData.shift(1)).*Msvm.ScaleData.scaleFactor(1), (Xdata(:, 2)+Msvm.ScaleData.shift(2)).*Msvm.ScaleData.scaleFactor(2)];
            decision = sum(Msvm.Alpha.*(Msvm.SupportVectors(:, 1))).*dataTrans(:, 1)+sum(Msvm.Alpha.*(Msvm.SupportVectors(:, 2))).*dataTrans(:, 2)+Msvm.Bias;
            
            [~, ii] = min(abs(decision));

            B = -W1*Xdata(ii, 1)-W2*Xdata(ii, 2);
            classObj.Weights = [W1, W2];
            classObj.Biases = B;
            classObj.D = 2;
            
            
            classObj.NNth = 0;
            save([metName '/classifier'], 'classObj');
        case 'NN'
            Iy = zeros(S(1), S(2)); % Iy holds the y position
            for row = 1:S(1)
                Iy(row, :) = ones(1, S(2)).*row;
            end
            X = [Crand2(:, 1) Iy(Crand2(:, 3))]; % Place data in X and Y variables
            Y = Crand2(:, 2);
            
            NN = NNReg(11, 1, [3, 1], {'Momentum', 1e-6, 0.1}, true);
            NN = NN.initWeights(0, 1, {'None', 'aa'});
            Xtrain = NN.trans11(X);
            NN = NN.train(Xtrain, Y, 50000);
            
            Xval = [Cval(:, 1) Iy(Cval(:, 3))]; % Place data in X and Y variables
            Yval = Cval(:, 2);
            Xval = NN.trans11(Xval);
            Z = NN.predict(Xval);
            
            maxCorr = 0;
            maxTH = [];
            for TH = 0.1:0.01:1
                Ztest = double(Z>TH);
                CCount = sum(double(Yval==Ztest));
                if CCount>maxCorr
                    maxCorr = CCount;
                    maxTH = TH;
                end
            end
            
            figure
            scatter3(X(:, 1), X(:, 2), Y);
            hold on
            scatter3(Xval(:, 1), Xval(:, 2), Z);
            classObj.NN = NN;
            classObj.NNth = maxTH;
            save([metName '/classifier'], 'classObj');
        case 'LinearTH'
            classObj.D = 1; % This classifier doesn't get trained, it gets tuned
            classObj.Weights = [1, 1];
            classObj.Biases = 1;
            save([metName '/classifier'], 'classObj');
        case 'AD-TH' % Adaptive threshold and threshold combination, gets tuned by showClassifier
            classObj.adthW = 15;  % Initial values for adaptive thresholding
            classObj.adthP = 0.5;
            classObj.Sigma = 2;
            classObj.Biases = -0.5;
            save([metName '/classifier'], 'classObj');
    end
else
    I = microImInputRaw(spm, T, cm, 1);
    dirCon{2} = [dirCon{2}; spm T cm];
    Im = max(I, [], 3); % Just print out a maximum projection
    maxp = max(Im(:)); minp = min(Im(:));
    Im2 = (Im-minp)./(maxp-minp);
    imwrite(Im2, [metName '/' num2str(size(dirCon{2}, 1)) '.tif']);
    save([metName '/dirCon'], 'dirCon');
end
        
        
return;
end