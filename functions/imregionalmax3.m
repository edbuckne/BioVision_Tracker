function Ilog = imregionalmax3( I )
s = size(I);
if(length(s)==2)
    s=[s 1];
end
Ilog = zeros(s);

for z=1:s(3)
    for row=2:s(1)-1
        for col=2:s(2)-1
            
            if(I(row,col,z)>=I(row-1,col,z) && I(row,col,z)>=I(row+1,col,z) &&... %xy plane neighbors
               I(row,col,z)>=I(row,col-1,z) && I(row,col,z)>=I(row,col+1,z))
                if(s(3)==1)
                    Ilog(row,col) = 1;
                    continue;
                end
                if(z==1)
                    if(I(row,col,z)>=I(row,col,z+1))
                        Ilog(row,col,z)=1;
                    end
                elseif(z==s(3))
                    if(I(row,col,z)>=I(row,col,z-1))
                        Ilog(row,col,z)=1;
                    end
                else
                    if(I(row,col,z)>=I(row,col,z-1) && I(row,col,z)>=I(row,col,z+1))
                        Ilog(row,col,z)=1;
                    end
                end
            end
        end
    end
end

