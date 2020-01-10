spm = 1;
cm = 1;
t = 1;

for spm = 5:13
clear data
load(['SPM' num2str(spm, '%.2u') '/cell_location_information.mat'])
load(['SPM' num2str(spm, '%.2u') '/shape_info.mat'])
load(['SPM' num2str(spm, '%.2u') '/cylCoord.mat'])

data.phloemall = [];
data.phloemallD = [];
data.phloemmulti = [];
data.phloemmultiD = [];
data.phloemnotmulti = [];
data.phloemnotmultiD = [];

I = microImInputRaw(spm, t, cm, 1);

iRange = timeArray(t, 1):timeArray(t, 2);
xyPoints = clInfo(iRange, 1:2);

Imax = spreadPixelRange(max(I, [], 3));
figure
imshow(Imax./0.5)
hold on
scatter(xyPoints(:, 1), xyPoints(:, 2))
[x, y] = ginput(100);
close all

%% Decide which points were chosen
M = distmatrix2d(xyPoints, [x, y]);

chosenpoints = zeros(length(x), 1);  % Notes the connections of user identified and software identified

for i = 1:size(M, 2)
    [~, id] = min(M(:, i));
    chosenpoints(i) = id + timeArray(t, 1) - 1;  % Notes the id of the chosen points and makes a connection
end
figure
imshow(Imax./0.5)
hold on
scatter(clInfo(chosenpoints, 1), clInfo(chosenpoints, 2));

%% Collect merged points
figure
imshow(Imax./0.5)
hold on
scatter(clInfo(chosenpoints, 1), clInfo(chosenpoints, 2))
[xmult, ymult] = ginput(100);
close all

%% Decide which poits were chosen for merged points
M = distmatrix2d([x, y], [xmult, ymult]);  % Get the distance of chosen enucleating points

chosenenucleatingpoints = zeros(length(xmult), 1);  % Notes the connections of user identified and software identified

for i = 1:size(M, 2)
    [~, id] = min(M(:, i));
    chosenenucleatingpoints(i) = chosenpoints(id);  % Notes the id of the chosen points and makes a connection
end
figure
imshow(Imax./0.5)
hold on
scatter(clInfo(chosenenucleatingpoints, 1), clInfo(chosenenucleatingpoints, 2));
[~,~] = ginput(1);
close all

%% Collect data for identifying multipoints
collectcombinedmulti = [shapeInfo(chosenenucleatingpoints, :), cylCoord(chosenenucleatingpoints, :)];
collectcombinednotmulti = [];
data.phloemnotmulti = [];

for i = 1:size(chosenpoints, 1)
    a = double(chosenenucleatingpoints == chosenpoints(i)); 
    if a == 0
        collectcombinednotmulti = [collectcombinednotmulti; shapeInfo(chosenpoints(i), :), cylCoord(chosenpoints(i), :)];
        data.phloemnotmulti = [data.phloemnotmulti; chosenpoints(i)];
    end
end

%% Store data
data.phloemall = chosenpoints;
data.phloemmulti = chosenenucleatingpoints;
data.phloemmultiD = collectcombinedmulti;
data.phloemnotmultiD = collectcombinednotmulti;
data.phloemallD = [data.phloemnotmultiD; data.phloemmultiD];

%% Saving options
if exist('../phloemTrainingData.mat')
    datatmp = data;
    load('../phloemTrainingData.mat');
    data = [data; datatmp];
end
save('../phloemTrainingData.mat', 'data');

end