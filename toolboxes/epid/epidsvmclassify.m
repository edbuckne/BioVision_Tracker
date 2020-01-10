function [Y] = epidsvmclassify(mdl, X, norm, mu, sd)
% epidsvmclassify.m takes in the support vector machine model (mdl) and the
% Nx10 array (X) that holds the features for each observation and returns
% the label for each observation based on the svm model.
% Additional inputs:
%   norm (logical) - indicates whether or not the data should be normalized
%   mu (1x10 double) - mean of each feature
%   sd (1x10 double) - standard deviation of each feature

N = size(X, 1);  % Number of observations
D = size(X, 2);  % Number of features

if exist('norm', 'var')  % Normalize the data
    if norm
        for d = 1:D
            X(:, d) = (X(:, d)-mu(d))./sd(d);
        end
    end
end

[Y, ~] = predict(mdl, X);  % Using the trained svm

mu = mean(X, 1);  % Eliminate outliers
sd = sqrt(var(X, 0, 1));
normdata = X;
for d = 1:size(X, 2)
    normdata(:, d) = (X(:, d)-mu(d))./sd(d);
end
normdata = double(normdata>3) + (normdata<(-3));
normdatasum = sum(normdata, 2);
Y(normdatasum>0) = 0;

end

