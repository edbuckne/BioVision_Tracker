function [ del ] = regPM2D( P, Q, maxDis, t )
%t is usually 5

dxmax = 0;
dymax = 0;
Nmax = 0;
T = eye(3); %Translation matrix

sp = size(P);
sq = size(Q);
Pp = [P; zeros(1,sp(2))+1]; %Insert an all ones row below the cell locations
Qp = [Q; zeros(1,sq(2))+1];

D = zeros(sp(2), sq(2)); %Distance matrix

for dx=-maxDis(1):t  :maxDis(1)
    for dy=-maxDis(2):t:maxDis(2)
        T(1:2,3) = [dx; dy];
        Qi = T*Qp; %Matrix multiplication for translation matrix Tk
        for i=1:sp(2)
            D(i,:) = sqrt((Pp(1,i)-Qi(1,:)).^2+(Pp(2,i)-Qi(2,:)).^2); %Calculating the Distance matrix
        end
        Dl = D<t;
        sd = sum(Dl(:));
        if(sd>Nmax)
            Nmax = sd;
            dxmax = dx;
            dymax = dy;
        end
    end
end

disp('IT2');
dxmax2 = dxmax;
dymax2 = dymax;
for dx=dxmax-t:dxmax+t
    for dy=dymax-t:dymax+t
        T(1:2,3) = [dx; dy];
        Qi = T*Qp; %Matrix multiplication for translation matrix Tk
        for i=1:sp(2)
            D(i,:) = sqrt((Pp(1,i)-Qi(1,:)).^2+(Pp(2,i)-Qi(2,:)).^2); %Calculating the Distance matrix
        end
        Dl = D<t;
        sd = sum(Dl(:));
        if(sd>Nmax)
            Nmax = sd;
            dxmax2 = dx;
            dymax2 = dy;
        end
    end
end
del = [dxmax2 dymax2];
end

