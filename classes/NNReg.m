classdef NNReg
    % Example call:
    %
    % test = NNReg(2, 4, [3, 2, 4, 2, 1], 0.001);
    % test = test.initWeights(1, 0.1);
    
    properties
        S
        LR
        InputNo
        HiddenLayers
        Nodes
        L
        LTrain
        ND
        MuX
        MuY
        SigX
        SigY
        trackData
        LearnMeth % Learning rate update method
    end
    
    methods
        function obj = NNReg(InputN, HLayers, Nodes, LearnMeth, NormData) % Creates the architecture of the regressional NN
            %{
            Inputs:
                > InputN - Integer value for the number of dimensions found
                    in the input data. Example: 5
                > HLayers - Integer value for the number of hidden layers
                    found in the network. Example: 2
                > Nodes - Vector of integers telling how many nodes are in
                    each hidden layer and output layer. Note that the
                    length of the Nodes vector much be HLayers+1.
                    Example: [2, 4, 1]
                > LearnMeth - Cell with learning rate update method with
                    parameters. Example: {'Momentum', 0.000001, 0.1}
                    > 'None' - constant learning rate for all weights
                        {'None', Learning Rate}
                    > 'Momentum' - update of weights based on momentum
                        {'Momentum', Learning Rate, alpha}
            %}
            
            obj.InputNo = InputN; % Collect information and store into object
            obj.HiddenLayers = HLayers;
            obj.Nodes = Nodes;
            obj.ND = NormData;
            obj.LearnMeth = LearnMeth;
            
            obj.S = cell(HLayers+2, 1); % Number of hidden layers
            obj.S{1} = cell(InputN, 1); % Number of input nodes
            % obj.S{end} = cell(1); % For now, output will always be 1
            
            for k = 1:HLayers+1
                obj.S{k+1} = cell(Nodes(k), 1); % Create the nodes for each hidden layer
            end
        end
        
        function obj = initWeights(obj, mu, std, mode)
            % Initializes all weights and biases based on random values
            % given by a normal distribution with mean mu and standard
            % deviation std.
            if(strcmp(mode{1}, 'Load'))
                load(mode{2});
            end
            for k = 1:obj.HiddenLayers+1 % Go through all hidden layers and output layer
                for j = 1:obj.Nodes(k)
                    obj.S{k+1}{j} = cell(5, 1); % Cells have the following information
                    % 1. Current weights and biases
                    % 2. Forward pass values
                    % 3. Backward pass weights (partial of Loss W.R.T. weights
                    % 4. Backward pass outputs (partial of Loss W.R.T. output of nodes
                    % 5. Learning rate parameters of each weight
                    if(strcmp(mode{1}, 'Load'))
                        obj.S{k+1}{j}{1} = objSave.S{k+1}{j}{1};
                    else
                        obj.S{k+1}{j}{1} = normrnd(mu, std, [length(obj.S{k})+1, 1]); % Randomize the weights
                    end
                    if(strcmp(obj.LearnMeth{1}, 'None')) % Non-adaptive learning rate
                        obj.S{k+1}{j}{5} = obj.LearnMeth{2}.*ones(length(obj.S{k})+1, 1); % Learning rate is just LR for constant learning rate
                    elseif(strcmp(obj.LearnMeth{1}, 'Momentum'))
                        obj.S{k+1}{j}{5} = [obj.LearnMeth{2}.*ones(length(obj.S{k})+1, 1),... % Learning rate
                            obj.LearnMeth{3}.*ones(length(obj.S{k})+1, 1),... % alpha parameter
                            zeros(length(obj.S{k})+1, 1)]; % velocity term
                    end
                end
            end
            
            if(strcmp(mode{1}, 'Save'))
                objSave = obj;
                save(mode{2}, 'objSave');
            end
        end
        
        function obj = train(obj, X, Y, Epochs)
            disp('Training the regressive neural network ...')
            if(obj.ND) % Normalize the data
                obj.MuX = mean(X, 1);
                obj.SigX = std(X);
                obj.MuY = mean(Y, 1);
                obj.SigY = std(Y);
                
                for i = 1:size(X, 1)
                    X(i, :) = (X(i, :)-obj.MuX)./obj.SigX;
                    Y(i) = (Y(i)-obj.MuY)./obj.SigY;
                end
            end
            f = waitbar(0, 'Training Network');
            for e = 1:Epochs
                waitbar(e/Epochs, f, ['Epoch ' num2str(e) ' of ' num2str(Epochs) ': Loss = ' num2str(obj.L)]);
                obj = obj.forwardPass(X);
                obj = obj.backwardPass(Y);
                obj = obj.updateWeights();
                obj.LTrain = [obj.LTrain; obj.L];
                if e == 1
                    continue;
                elseif(abs(obj.LTrain(end)-obj.LTrain(end-1))<0.001)
%                     break;
                end
                obj.trackData = [obj.trackData; (obj.S{2}{1}{1})'];
            end
            close(f)
        end
        
        function obj = forwardPass(obj, X)
            N = size(X, 1); % Find the number of data points
            
            % Push data values into the network
            for j = 1:obj.InputNo % Go through each dimension of the input
                obj.S{1}{j}{2} = X(:, j);
            end
            for k = 1:obj.HiddenLayers+1 % Go through hidden layers and output layer on the forward pass
                for j = 1:obj.Nodes(k) % Forward pass through node in that layer
                    obj.S{k+1}{j}{2} = zeros(N, 1); % zeros for sum
                    %for n = 1:N % Go through each data point
                    c = zeros(N, 1);
                    for w = 1:length(obj.S{k})
                        c = c+obj.S{k}{w}{2}.*obj.S{k+1}{j}{1}(w+1); % multiplying j * w
                    end
                    obj.S{k+1}{j}{2} = c+obj.S{k+1}{j}{1}(1); % Adding the bias term
                    %end
                    
                end
            end
        end
        
        function obj = backwardPass(obj, Y)
            % Calculates the loss and back propogates the partial
            % derivatives for each weight
            
            % Begin by finding the loss function and partial with respect
            % to the output node output and output node weights
            [obj, dLdy] = obj.calcLoss(Y);
            obj.S{end}{1}{3} = zeros(size(dLdy, 1), length(obj.S{end}{1}{1})); % Partial derivatives of weights of output node
            obj.S{end}{1}{4} = dLdy; % Partial derivative of output of output node
            for w = 1:length(obj.S{end}{1}{1})-1 % Go through each weight in output layer
                obj.S{end}{1}{3}(:, w+1) = obj.S{end}{1}{4}.*obj.S{end-1}{w}{2}; % Multiply partial of loss with output of previous layer
            end
            obj.S{end}{1}{3}(:, 1) = obj.S{end}{1}{4}; % Partial derivative for the bias weight of the output layer
            
            % Now go through each node in the hidden layers and calculate
            % partial derivatives for each output and each weight.
            for k = obj.HiddenLayers:-1:1 % Go through each hidden layer
                for j = 1:length(obj.S{k+1}) % Go through each node in each hidden layer
                    obj.S{k+1}{j}{3} = zeros(size(dLdy, 1), length(obj.S{k+1}{j}{1})); % Initialize partials of weights to zero
                    obj.S{k+1}{j}{4} = zeros(size(dLdy, 1), 1); % Initialize partial of outputs to zero
                    for i = 1:length(obj.S{k+2}) % Look at the output of each node in the next layer
                        obj.S{k+1}{j}{4} = obj.S{k+1}{j}{4}+obj.S{k+2}{i}{4}.*obj.S{k+2}{i}{1}(j+1); % dLdoutput of next * weight of next layer
                    end
                    for w = 1:length(obj.S{k+1}{j}{1})-1 % go through each weight in the node
                        obj.S{k+1}{j}{3}(:, w+1) = obj.S{k+1}{j}{4}.*obj.S{k}{w}{2}; % Partial of output * previous layer output
                    end
                    obj.S{k+1}{j}{3}(:, 1) = obj.S{k+1}{j}{4};
                end
            end
            
        end
        
        function [obj, dLdy] = calcLoss(obj, Y)
            % Calculates and returns the loss value based on the difference
            % of squares function. Also returns partial derivative
            
            dataSub = obj.S{end}{1}{2}-Y; % Subtract output of network with true values
            obj.L = sum(dataSub.^2);
            dLdy = 2.*dataSub;
        end
        
        function obj = updateWeights(obj)
            % Updates the weights of each node according to the learning
            % rate and backward pass values
            
            for k = 1:obj.HiddenLayers+1
                for j = 1:length(obj.S{k+1})
                    if(strcmp(obj.LearnMeth{1}, 'None')) % Constant learning rate SGD
                        %obj.S{k+1}{j}{1} = obj.S{k+1}{j}{1} - obj.S{k+1}{j}{5}(:, 1).*(sum(obj.S{k+1}{j}{3}, 1))'; % SGD operator
                        obj.S{k+1}{j}{1} = obj.S{k+1}{j}{1} - obj.LearnMeth{2}.*(sum(obj.S{k+1}{j}{3}, 1))';
                    elseif(strcmp(obj.LearnMeth{1}, 'Momentum')) % SGD with momentum
                        % Update velocity term
                        %                         obj.S{k+1}{j}{5}(:, 3) = obj.S{k+1}{j}{5}(:, 2).*obj.S{k+1}{j}{5}(:, 3)-... % alpha*velocity
                        %                                                  obj.S{k+1}{j}{5}(:, 1).*(sum(obj.S{k+1}{j}{3}))'; % learning rate % gradient
                        obj.S{k+1}{j}{5}(:, 3) = obj.S{k+1}{j}{5}(:, 2).*obj.S{k+1}{j}{5}(:, 3)-... % alpha*velocity
                            obj.LearnMeth{2}.*(sum(obj.S{k+1}{j}{3}))'; % learning rate % gradient
                        obj.S{k+1}{j}{1} = obj.S{k+1}{j}{1}+obj.S{k+1}{j}{5}(:, 3); % Update weights
                    end
                end
            end
        end
        
        function p = predict(obj, X)
            if(obj.ND)
                for i = 1:size(X, 1)
                    X(i, :) = (X(i, :)-obj.MuX)./obj.SigX;
                end
                obj = obj.forwardPass(X);
                p = (obj.S{end}{1}{2}.*obj.SigY)+obj.MuY;
            else
                obj = obj.forwardPass(X);
                p = obj.S{end}{1}{2};
            end
            
            
        end
        function Xout = trans11(~, X)
            Xout = [];
            Sdata = size(X, 2); % How many columns of data/dimensions
            
            Xout = [Xout, X, X.^2, X.^3];
            for i = 1:Sdata
                tmp1 = X(:, i).^2;
                tmp2 = X(:, i);
                tmp3 = X(:, i).^3;
                tmp4 = X(:, i);
                for j = 1:Sdata
                    if j==i
                        continue;
                    else
                        tmp1 = tmp1.*X(:, j);
                        tmp2 = tmp2.*(X(:, j).^2);
                        tmp3 = tmp3.*X(:, j);
                        tmp4 = tmp4.*(X(:, j).^3);
                    end
                    
                end
                Xout = [Xout, tmp1, tmp2];
            end
        end
        
    end
end
    
