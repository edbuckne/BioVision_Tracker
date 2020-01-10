function [net] = trainDataset(loadName, saveName, fifty)
load(loadName);

if fifty
    Y1 = Y(:, 1)==1;
    Y1sum = sum(Y1);
    Y2 = Y(:, 2)==1;
    Y2sum = sum(Y2);
    [minVal, i] = min([Y1sum, Y2sum]);
    
    if i==1
        Xother = X(Y(:, 2)==1, :); Yother = Y(Y(:, 2)==1, :);
        randSamp = randsample(size(Xother, 1), minVal);
        X1 = X(Y(:, 1)==1, :); Y1 = Y(Y(:, 1)==1, :);
        X2 = Xother(randSamp, :); Y2 = Yother(randSamp, :);
    elseif i==2
        Xother = X(Y(:, 1)==1, :);
        randSamp = randsample(size(Xother, 1), minVal);
        X1 = X(Y(:, 2)==1, :); Y1 = Y(Y(:, 2)==1, :);
        X2 = Xother(randSamp, :); Y2 = Yother(randSamp, :);
    end
    
    X = [X1; X2]; 
    Y = [Y1; Y2];
end
inputs = X';
targets = Y';

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

save(saveName, 'net', 'features');
end

