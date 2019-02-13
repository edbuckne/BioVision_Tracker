function showRec3( spm, tm, samp_red, varargin )
% showRec3.m takes in the specimen number, time stamp, and options and
% reconstructs the surface/midline/gene expression on a 3D map.
% The B variable is assumed to be the Nx2 contour points, where the first column is Y
% positions and the second column is the X positions. Also, the S variable
% is assumed to be the M sized midline points (X positions only).

load('data_config.mat')
filtOrd = 200;

I = microImInputRaw(spm, tm, 2, 1); 
SS = size(I);
clear I

spm_str = ['SPM' num2str(spm, '%.2u')];
cd([spm_str '/MIDLINE']); % Go to specimen midline directory

load(['ml' num2str(tm, '%.4u')]); % Load reconstruction data
% Imask = im2double(imread(['mask' num2str(tm, '%.4u') '.tif']));

if ~isempty(varargin) % If there is no varargin, set mode to default
    mode = varargin{1};
else
    mode = 'default';
end

% Begin algorithm

filtForm = ones(1, filtOrd)./filtOrd; % Filter the contour
B(:, 2) = filtfilt(filtForm, 1, B(:, 2));
R = S; % R holds the radius

for i = 1:length(S)
    PP = B(:, 1)==i; % Find all contour points at this y location and find min and max x values
    xMin = min(B(PP, 2));
    xMax = max(B(PP, 2));
    
    R(i) = ((S(i)-xMin)+(xMax-S(i)))/2; % Find the average radius value
end
Rmax = max(R);
RZadd = ceil(Rmax/xyratz)+1;

Ir = zeros(SS(1), SS(2)); 
Ix = Ir; % Holds the x position across all columns
Imz = zeros(SS);
Isy = zeros(SS(1), SS(2));
Imask = zeros(SS(1), SS(2), RZadd*2);

V1 = [B(:, 2), B(:, 1), zeros(length(B(:, 1)), 1)]; % View 1 contour
ML = [S, (1:length(S))', zeros(length(S), 1)]; % 3D midline variable

switch mode
    case 'default'
        for x = 1:SS(2)
            Ix(:, x) = Ix(:, x)+x;
        end
        for y = 1:length(S)
            Isy(y, :) = Isy(y, :)+S(y);
            Ir(y, :) = Ir(y, :)+R(y);
        end
        IxMsy = (Ix-Isy).^2;
        for z = 1:RZadd*2
            Imask(:, :, z) = sqrt(IxMsy+(xyratz.*(z-RZadd))^2)-Ir;
        end
        Imask = Imask<0;
        Imask = imresize(Imask, [round(SS(1)/samp_red), round(SS(2)/samp_red)]);
        Imask = flip(Imask, 1);
        
        figure
        p = patch(isosurface(Imask));
        p.FaceColor = 'blue';
        p.EdgeColor = 'none';
        % p.FaceAlpha = 0.5;
        daspect([1 1 samp_red/xyratz]);
        axis tight
        camlight
        lighting gouraud
    otherwise

end

cd('../..')
end

