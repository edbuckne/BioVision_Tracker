function [mdl, res, mu, sd] = epidtrainsvm(X, Y, partition, norm, fifty)
% epidtrainsvm.m takes in the NxD array (X), where N is the number of
% observations and D is the number of features, the Nx1 array (Y) that
% holds the class label for each observation, a 1x2 array (partition) which
% holds the fractions of [train test] partitions of the data, a logical
% variable (norm) which tells if the data should be normalized, and a
% logical variable (fifty) which tells if training should be done with an
% equal number of each class.

N = size(X, 1);
D = size(X, 2);

c = cvpartition(N, 'HoldOut', partition(2));
trainidx = training(c);
testidx = test(c);

Xtrain = X(trainidx, :); Ytrain = Y(trainidx, :);
Xtest = X(testidx, :); Ytest = Y(testidx, :);

if fifty
    Y1 = Ytrain(:, 1)==1;
    Y1sum = sum(Y1);
    Y2 = Ytrain(:, 1)==0;
    Y2sum = sum(Y2);
    [minVal, i] = min([Y1sum, Y2sum]);
    
    if i==1
        Xother = Xtrain(Ytrain==0, :); Yother = Ytrain(Ytrain==0, :);
        randSamp = randsample(size(Xother, 1), minVal);
        X1 = Xtrain(Ytrain==1, :); Y1 = Ytrain(Ytrain==1, :);
        X2 = Xother(randSamp, :); Y2 = Yother(randSamp, :);
    elseif i==2
        Xother = Xtrain(Ytrain==1, :); Yother = Ytrain(Ytrain==1, :);
        randSamp = randsample(size(Xother, 1), minVal);
        X1 = Xtrain(Ytrain==0, :); Y1 = Ytrain(Ytrain==0, :);
        X2 = Xother(randSamp, :); Y2 = Yother(randSamp, :);
    end
    
    Xtrain = [X1; X2]; 
    Ytrain = [Y1; Y2];
end

if norm
    mu = mean(X, 1);
    sd = sqrt(var(X, 0, 1));
    
    for i = 1:size(Xtrain, 1)
        Xtrain(i, :) = (Xtrain(i, :) - mu)./sd;
    end
    for i = 1:size(Xtest, 1)
        Xtest(i, :) = (Xtest(i, :) - mu)./sd;
    end
else
    mu = [];
    sd = [];
end

mdl = fitcsvm(Xtrain, Ytrain, 'KernelFunction', 'polynomial');

[svmtrain, ~] = predict(mdl, Xtrain);
[svmtest, ~] = predict(mdl, Xtest);

trainacc = sum(double(svmtrain==Ytrain))./length(Ytrain);
testacc = sum(double(svmtest==Ytest))./length(Ytest);
res = struct('trainacc', trainacc, 'testacc', testacc);
end

