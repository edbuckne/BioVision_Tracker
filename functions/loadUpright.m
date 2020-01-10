function [Iur] = loadUpright(spm, t, cm, I)
Imask = im2double(imread(['SPM' num2str(spm, '%.2u') '/MIDLINE/mask' num2str(t, '%.4u') '.tif']));

[Cxy] = calcCxy(Imask);
[Vx, Vy] = calcVxVy(Imask);

C = [Cxy, Vx; Vy, Cxy];

[EVec, EVal] = eig(C);

if abs(EVal(1, 1))>abs(EVal(2, 2))
    rang = atand(EVec(1, 1)/EVec(2, 1));
else
    rang = atand(EVec(1, 2)/EVec(2, 2));
end

if ~exist('I', 'var')
    I = microImInputRaw(spm, t, cm, 1);
    Imax = spreadPixelRange(max(I, [], 3));
else
    Imax = I;
end
Iur = imrotate(Imax, -rang);
end

