function OUT_IMAGES = yStacks(Iint)
disp('Creating y stacks');

%Read the first image to get a size measurement
s = size(Iint); %Size of image
OUT_IMAGES = zeros(s(3),s(2),s(1));

for y=1:1:s(1)
    for z=1:s(3)
        OUT_IMAGES(z,:,y) = Iint(y,:,z); %Create new images
    end
end
disp(['Created ' num2str(s(1)) ' y stacks']);

end

