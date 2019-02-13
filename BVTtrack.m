function BVTtrack( varargin )
% BVTtrack.m
%
% Highest level function on the BVT software pipeline. This function takes
% in the delta shift information and the raw cell location information and
% indicates the parent-child relationships between each adjacent time
% stamp.

load('data_config');

load('data_config.mat');
if(size(varargin,1)==0) % Get the specimen information
    SPM = input('Which specimen do you want to track? ');
else
    SPM = varargin{1};
end

sInd = find(tSpm(:, 1)==SPM);
tmStart = tSpm(sInd, 2); tmEnd = tSpm(sInd, 3);
cd(['SPM' num2str(SPM, '%.2u')]); % Go to specimen directory 

load('zStacks');
load('cell_location_information.mat'); %Get the cell information
load('delta_set'); %Image registration data

T = eye(4);
THDist = 40;
i = 1;
s = size(clInfo);

% timeArray = zeros(tmEnd-tmStart+1,2); %This holds the time separation info of clInfo 
PC = zeros(s(1),2); %holds the parent/child relationships and their distances
PC2 = zeros(s(1),2); %holds the parent/child relationships and their distances

% for t=tmStart:tmEnd
%     timeArray(t,1) = i; %The beginning pointer of this time stamp
%     while(clInfo(i,10)==t && i<s(1))
%         i=i+1; %Increment i to continue looking for the end of this time stamp
%     end
%     if~(i==s(1))
%         timeArray(t,2) = i-1;
%     else
%         timeArray(t,2) = i;
%     end
% end

i=1;
j=1;
for t=tmStart:tmEnd-1 %Get the points from the clInfo array
    if((timeArray(t,1)==0)||(timeArray(t+1,1)==0))
        continue
    end
    i = timeArray(t, 1);
    t0Points = clInfo(timeArray(t,1):timeArray(t,2),1:3)'; %COM points first time point
    t1Points = clInfo(timeArray(t+1,1):timeArray(t+1,2),1:3)'; %COM points second time point
    
    T(1:3,4) = delSet(t,1:3)'; %Transformation matrix
    
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
            PC(i,1) = childI+timeArray(t+1,1)-1;
        else
            PC(i,1)=0;
        end
        i=i+1;
    end
   
end
for i=1:s(1) %Now find the parents to each 
    found = 0;
    j = 1;
    while(j<=s(1) && ~(PC(j,1)==i))
        j=j+1;
    end
    if~(j>=s(1))
        PC(i,2) = j;
    end
end
save('PC_Relationships','PC');
cd ..


end

