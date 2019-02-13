function [ Iclass ] = classifyImage( CO, I )
% classifyImage - Takes in a classifier object CO from the BVT library and a 3
% dimensional image for the classifier to be applied to.  The output of the
% function is Iclass, a 3 dimensional image of the same size and shape of
% input I. Iclass is a logical image that contains 1 for positive class and
% 0 for the negative class.
%
% Author - Eli Buckner

s = size(I);
if length(s)==2
    s = [s, 1];
end
% if length(s)>2
%     for z = 1:s(3)
%         I(:, :, z) = imgaussfilt(I(:, :, z), CO.Sigma);
%     end
% else
%     I = imgaussfilt(I, CO.Sigma);
% end

if strcmp(CO.Type, 'TH')
    I1 = I;
elseif strcmp(CO.Type, 'SVM-Y')||strcmp(CO.Type, 'NN')
    Iy = zeros(s); % Create an image that contains the y position in each pixel
    for y = 1:s(1)
        Iy(y, :, :) = ones(1, s(2), s(3)).*y; % Create the image
    end
    I1 = I; % Assign I1 and I2
    I2 = Iy;
end

if strcmp(CO.Type, 'NN')
    if length(s)==3 % If the image is 3D
        Iclass = zeros(s);
        f = waitbar(0, ' ');
        for z = 1:s(3)
            waitbar(z/s(3), f, ['Semantic segmentation of image ... ' num2str(100*z/s(3), '%.2f') '%']);
            I11 = I1(:, :, z); I22 = I2(:, :, z);
            X = [I11(:), I22(:)];
            IcTmp = reshape(CO.NN.predict(CO.NN.trans11(X)), s(1:2))>CO.NNth;
            IcTmp = imfill(IcTmp, 'holes');
            Iclass(:, :, z) = IcTmp==1;
        end
        close(f)
    else
        X = [I1(:), I2(:)];
        Iclass = CO.NN.predict(CO.NN.trans11(X));
        Iclass = reshape(Iclass, size(I1))>CO.NNth;
    end
else
    if CO.D==1
        Iclass = CO.Weights(1).*I1+CO.Biases;
        Iclass = Iclass>0;
    elseif CO.D==2
        Iclass = -(CO.Weights(1).*I1+CO.Weights(2).*I2+CO.Biases); % Apply the weights and biases to the data
%         Iclass = Iclass>0;
        Iclass = Iclass>CO.NNth;
    end
end


end

