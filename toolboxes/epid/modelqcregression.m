function [A, B, C, fhand] = modelqcregression(X, Y, varargin)
% modelqcregression.m trains a regression model based on the data that is
% sent through the X and Y variables. X is the independent variable while Y
% is the dependent variable. This function returns A, B, and C values
% representing parameters of the different regression models specified
% below.
%   Linear: Y = AX + B
%   Exponential: Y = Ae^(BX) + C

defaultRegressionModel = 'linear';
defaultPlotSetting = false;
defaultIterations = 100000;
defaultA = 1;
defaultB = 0.01;
defaultC = 100;
defaultD = 0.1;
defaultE = 1;
defaultKA = 0.001;
defaultKB = 0.000000000001;
defaultKC = 0.001;

expectedRegressionModel = {'linear', 'exponential'};

p = inputParser();
addRequired(p, 'X');  % The dependent variable
addRequired(p, 'Y');  % The independent variable
addParameter(p, 'Iterations', defaultIterations);  % The maximum number of iterations to use for the fitting
addParameter(p, 'A', defaultA);  % The initial conditions for the parameters
addParameter(p, 'B', defaultB);
addParameter(p, 'C', defaultC);
addParameter(p, 'D', defaultD);
addParameter(p, 'E', defaultE);
addParameter(p, 'KA', defaultKA);
addParameter(p, 'KB', defaultKB);
addParameter(p, 'KC', defaultKC);
addParameter(p, 'RegressionModel', defaultRegressionModel, ...  
    @(x) any(validatestring(x, expectedRegressionModel)));  % 'linear': linear regression model, 'exponential': exponential regression model
addParameter(p, 'PlotSetting', defaultPlotSetting, ...
    @(x) islogical(x));  % true: plot the regression model versus the data, false: do not plot

parse(p, X, Y, varargin{:});

A = p.Results.A;  % Initialize the parameters
B = p.Results.B;
C = p.Results.C;
D = p.Results.D;
E = p.Results.E;
Ka = p.Results.KA;
Kb = p.Results.KB;
Kc = p.Results.KC;

if strcmp(p.Results.RegressionModel, 'exponential')
%     for i = 1:p.Results.Iterations  % Fitting the model using maximum log likelihood
%         loglike1 = log(1./(sqrt(2.*pi).*(D.*X)));
%         loglike2 = - ((Y-A.*exp(B.*X)-C).^2)./(2.*(D.*X+E).^2);
%         loglike = sum(loglike1 + loglike2);
% 
%         logdiva = sum((2.*(Y-A.*exp(B.*X)-C).*(exp(B.*X)))./(2.*(D.*X+E).^2));
%         logdivb = sum((2.*(Y-A.*exp(B.*X)-C).*(A.*X.*exp(B.*X)))./(2.*(D.*X+E).^2));
%         logdivc = sum((2.*(Y-A.*exp(B.*X)-C))./(2.*(D.*X+E).^2));
% 
%         A = A + Ka .* logdiva;
%         B = B + Kb .* logdivb;
%         C = C + Kc .* logdivc;
%     end
    f = @(b,X) b(1).*exp(b(2).*X)+b(3);                                     % Objective Function
    Bpar = fminsearch(@(b) norm(Y - f(b,X)), [1; 0.01; 100]);
    
    A = Bpar(1);
    B = Bpar(2);
    C = Bpar(3);
    fhand = @(A, B, C, X) A .* exp(B .* X) + C;
elseif strcmp(p.Results.RegressionModel, 'linear')
    xx = [ones(length(X), 1), X];
    b = xx\Y;
    
    A = b(2);  % Assign the weights to the output parameters
    B = b(1);
    C = [];
    
    fhand = @(A, B, C, X) A .* X + B;
end

if p.Results.PlotSetting
    xmin = min(X(:));
    xmax = max(X(:));
    inter = (xmax - xmin)./99;
    
    xplot = xmin:inter:xmax;
    yplot = fhand(A, B, C, xplot);
    
    figure
    scatter(X, Y, '+k');
    hold on
    plot(xplot, yplot, 'r');
    
    xlabel('X');
    ylabel('Y');
    title('Regression Model')
end
end

