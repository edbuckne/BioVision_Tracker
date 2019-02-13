function BVTreject( varargin )
% BVTreject.m - This function is to be run after entire pipeline has been
% completed for a sample. The user will identify the specimen to reject
% time stamps and the time stamps to be rejected. The function will go into
% the collected data for the specimen and insert NaN for all data in
% rejected ranges. It will then connect time stamps not rejected and
% evaluate them.
% Input:
%   varargin{1}:spm (int) - The specimen number to evaluate
%   varargin{2}:tRej (vec int) - Time stamps to reject.

load data_config
THDist = 40; % Maximum distance to indicate a parent child point match

if length(varargin)>=1 % Get the specimen number from input or user prompt
    spm = varargin{1};
else
    spm = input('Which specimen do you want to evaluate? ');
end
spmStr = ['SPM' num2str(spm, '%.2u')];
cd(spmStr); % Go to specimen directory
spmID = find(tSpm(:, 1)==spm);

if length(varargin)>=2 % Get the time stamps to reject from input or user prompt
    tRej = varargin{2};
else
    tIn = input('Input the range of time points to reject (eg. 1:5, or [1:5, 9] or [1, 5, 9]. ', 's');
    eval(['tRej = ', tIn]);
end

if length(varargin)>=3 % Get the maximum shift vetor from input or user prompt
    maxShift = varargin{3};
else
    tIn = input('Input the maximum shift vector as [x, y, z]. ', 's');
    eval(['maxShift = ' tIn]);
end

% Load data into RAM
load('cell_location_information');
load('delta_set');
load('PC_Relationships');
load('shape_info');
if exist('cylCoord.mat')
    load('cylCoord.mat')
end

if ~exist('oldData') % Store the old data in case something goes wrong
    mkdir('oldData')
    copyfile('cell_location_information.mat', 'oldData/cell_location_information.mat');
    copyfile('delta_set.mat', 'oldData/delta_set.mat');
    copyfile('PC_Relationships.mat', 'oldData/PC_Relationships.mat');
    copyfile('shape_info.mat', 'oldData/shape_info.mat');
    if exist('cylCoord.mat')
        copyfile('cylCoord.mat', 'oldData/cylCoord.mat');
    end
else
    warning('oldData folder already exists ...')
    inp = input('Do you want to continue? (1 - yes, 0 - no) ');
    if inp==0
        cd ..
        return;
    else % Delete what is currently in oldData and insert new old data
        cd oldData
        d = dir(pwd);
        for i = 3:length(d)
            delete(d(i).name);
        end
        cd ..
        
        copyfile('cell_location_information.mat', 'oldData/cell_location_information.mat');
        copyfile('delta_set.mat', 'oldData/delta_set.mat');
        copyfile('PC_Relationships.mat', 'oldData/PC_Relationships.mat');
        copyfile('shape_info.mat', 'oldData/shape_info.mat');
        if exist('cylCoord.mat')
            copyfile('cylCoord.mat', 'oldData/cylCoord.mat');
        end
    end
end

PC02 = PC;
ignVec = zeros(size(timeArray, 1), 1); % Vector holds a 1 when needing to reject
ignVec(varargin{2}) = 1;
for t = tSpm(spmID, 2):tSpm(spmID, 3) % Go through each time stamp
    if sum(double(tRej==t))==0 % If this time stamp is not on the list, go on
        continue;
    end
    tRejInd = clInfo(:, 10)==t; % Find indeces to reject
    
    timeArray(t, :) = NaN; % Set values to nothing
    statsTot(t, :) = NaN;
    clInfo(tRejInd, :) = NaN;
    shapeInfo(tRejInd, :) = NaN;
    PC02(tRejInd, :) = NaN;
    if exist('cylCoord.mat')
        cylCoord(tRejInd, :) = NaN;
    end
    
    if ignVec(t)==1
        tTmp = t;
        ignCount = 0; % Tells how many sequential time stamps were ignored
        while ignVec(tTmp)>0
            ignVec(tTmp) = 0; % Don't consider this time stamp later
            ignCount = ignCount + 1;
            tTmp = tTmp + 1; % Increment time stamp
        end
        Q = clInfo(timeArray(tTmp, 1):timeArray(tTmp, 2), 1:3)'; % First time stamp available after rejection range
        P = clInfo(timeArray(t-1, 1):timeArray(t-1, 2), 1:3)';
        
        newDel = regPM3D(P, Q, 5, maxShift, xyratz); % Find a new shift vector
        
        % Retracking PC relationship
        i = timeArray(t-1, 1);
        t0Points = P; %COM points first time point
        t1Points = Q; %COM points second time point
        
        T = eye(4);
        T(1:3,4) = newDel; %Transformation matrix
        
        dMat = disMat(t0Points,t1Points,T);
        dSize = size(dMat); %Get the size of the distance matrix
        
        for N=1:dSize(1) %Going through all of the distance matrix
            childI = 0; %Child index
            minDist = 100;
            for M=1:dSize(2)
                if(dMat(N,M)<THDist && abs(t0Points(3,N)-t1Points(3,M))<=abs(T(3,4))+5)
                    if(dMat(N,M)<minDist)
                        childI=M;
                        minDist = dMat(N,M);
                    end
                end
            end
            if~(childI==0)
                childI2 = 0; %Child index
                minDist2 = 100;
                for N2=1:dSize(1) %Check double verification
                    if(dMat(N2,childI)<THDist && abs(t0Points(3,N2)-t1Points(3,childI))<=abs(T(3,4))+5)
                        if(dMat(N2,childI)<minDist2)
                            childI2=N2;
                            minDist2 = dMat(N2,childI);
                        end
                    end
                end
                if ~(childI2==N)
                    i=i+1;
                    continue;
                end
            end
            if(childI>0) %We have found a PC relationship
                PC02(i,1) = childI+timeArray(tTmp,1)-1;
            else
                PC02(i,1)=0;
            end
            i=i+1;
        end
        s = size(clInfo);
        for i2=1:s(1) %Now find the parents to each
            j = 1;
            while(j<=s(1) && ~(PC02(j,1)==i2))
                j=j+1;
            end
            if~(j>=s(1))
                PC02(i2,2) = j;
            end
        end
    end
    
end
PC = PC02;

save('cell_location_information', 'clInfo', 'timeArray');
if exist('cylCoord.mat')
    save('cylCoord', 'cylCoord');
end
save('del_set', 'delSet');
save('PC_Relationships', 'PC');
save('shape_info', 'shapeInfo', 'statsTot');

cd ..
end