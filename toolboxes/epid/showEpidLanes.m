function [Ilane, imz] = showEpidLanes(SPM, t, plot)
% showEpidLanes.m prints the image of a specimen and overlayes the cell
% lanes that have been detected as the epidermal lanes. Note: EPIDlane.m
% must be run before this function can be called.
% Inputs:
%   SPM (int) - specimen number/identifier
%   t (int) - time stamp to evaluate
%   plot (logical) - option 
% Outpus:
%   Ilane (double image) - image of the root upright with superimposed
%   lanes. The blue lanes are non-epidermal and the red lanes are
%   epidermal.

spmDir = ['SPM' num2str(SPM, '%.2u')]; % Load the necessary data
datapath = [spmDir '/EPID/lanes' num2str(t, '%.4u')];
load(datapath);

f = figure;
imshow(imrotate(imz, angl));
hold on

for i = 1:length(allLanes) % Plot all lanes blue
    line(allLanes{i}(:, 1), allLanes{i}(:, 2), 'Color', 'b');
end

for i = 1:length(epidLanes) % Overlay epidermal lanes red
    line(epidLanes{i}(:, 1), epidLanes{i}(:, 2), 'Color', 'r');
end

if ~plot
    close(f)
end

saveas(f, 'tmp.jpg');
Ilane = im2double(imread('tmp.jpg'));
delete('tmp.jpg');
end

