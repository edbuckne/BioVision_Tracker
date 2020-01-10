function [Imax, f] = showMaxProj(spm, t, cm, spread, plot)
I = microImInputRaw(spm, t, cm, 1);
Imax = max(I, [], 3);
if spread
    Imax = spreadPixelRange(Imax);
end

if plot
    f=figure;
    imshow(Imax);
end
end

