features = [15, 22, 23, 25, 26, 27];  % xyCovariance, Tip Distance, Center Distance, Nearest neighbor, Same file count, Number below
dataSplit = [.70, .15, .15];  % Training, Validation, Test data split

load('phloemTrainingData.mat');
Sphloem = size(phloemData, 1);
SnotPhloem = size(notPhloemData, 1);

phloemTrain = phloemData(1:round(dataSplit(1)*Sphloem), features);  % Training data
notPhloemTrain = notPhloemData(1:round(dataSplit(1)*SnotPhloem), features);
Xtrain = [phloemTrain; notPhloemTrain];
Ytrain = [ones(size(phloemTrain, 1), 1); zeros(size(notPhloemTrain, 1), 1)];

phloemVal = phloemData(round(dataSplit(1)*Sphloem):(round(dataSplit(1)*Sphloem)+round(dataSplit(2)*Sphloem)), features);  % Validation data
notPhloemVal = notPhloemData(round(dataSplit(1)*SnotPhloem):(round(dataSplit(1)*SnotPhloem)+round(dataSplit(2)*SnotPhloem)), features);
Xval = [phloemVal; notPhloemVal];
Yval = [ones(size(phloemVal, 1), 1); zeros(size(notPhloemVal, 1), 1)];

phloemTest = phloemData((round(dataSplit(1)*Sphloem)+round(dataSplit(2)*Sphloem)):end, features);  % Testing Data
notPhloemTest = notPhloemData((round(dataSplit(1)*SnotPhloem)+round(dataSplit(2)*SnotPhloem)):end, features);
Xtest = [phloemTest; notPhloemTest];
Ytest = [ones(size(phloemTest, 1), 1); zeros(size(notPhloemTest, 1), 1)];
%% Training using my neural network
maxAcc = 0;
nodeMaxAcc = 0;
nodeTest = 2:10;
accData = zeros(length(nodeTest), 2);

Xval2 = NN.trans11(Xval);

for i = 1
    nodes = nodeTest(i)
    NN = NNReg(1, 1, [5, 1], {'None', 0.0001}, true);
    Xtrain2 = NN.trans11(Xtrain);
    NN = NNReg(size(Xtrain2, 2), 1, [nodes, 1], {'None', 0.0001}, true);
    NN = NN.initWeights(0, 0.001, {'Save', 'idk'});
    NN = NN.train(Xtrain2, Ytrain, 5000);
    
    maxAccTH = 0;
    maxTH = 0;
    disp('Checking threshold validation')
    valOutput = NN.predict(Xval2);
    for TH = 0.05:0.05:0.95
        vO = valOutput>TH;
        same = double(Yval==vO);
        acc = sum(same)/length(same);
        if acc>maxAccTH
            maxAccTH = acc;
            maxTH = TH;
        end
    end
    
    accData(i, 1) = maxAccTH;
    accData(i, 2) = maxTH;
    
    close all
    figure
    plot(nodeTest, accData);
end

%%
X = [phloemData(:, features); notPhloemData(:, features)]';
Y = [ones(1, Sphloem), zeros(1, SnotPhloem); ...
     zeros(1, Sphloem), ones(1, SnotPhloem)];

inputs = X;
targets = Y;

% Create a Pattern Recognition Network
hiddenLayerSize = 10;
net = patternnet(hiddenLayerSize);
net.trainParam.epochs=100;


% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,inputs,targets);

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);

% View the Network
view(net)