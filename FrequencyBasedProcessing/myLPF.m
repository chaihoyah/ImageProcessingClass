input=imread('racing-noisy.png');

figure,imshow(input);
title('Input Image');

% Get size
dimX = size(input,1);
dimY = size(input,2);

% Convert pixel type to float
[f, revertclass] = tofloat(input);

% Determine good padding for Fourier transform
PQ = paddedsize(size(input));
dimPadX = PQ(1);
dimPadY = PQ(2);
% Fourier tranform of padded input image
F = fft2(f,PQ(1),PQ(2));
F = fftshift(F);
figure,imshow(log(1+abs((F))), []);

% -------------------------------------------------------------------------

%
% Creating Frequency filter and apply - High pass filter
%
n = 2;
D0 = 100;
D = double(zeros(dimPadX,dimPadY));
for i=1:dimPadX
    for j=1:dimPadY
        D(i,j) = ((i-dimPadX/2)^2+(j-dimPadY/2)^2)^(1/2);
    end
end

H = 1./(1+(D./D0).^(2*n));
%
% ToDo
%
G = H.*F;

% -------------------------------------------------------------------------
figure,imshow(log(1+abs((G))), []);
% Inverse Fourier Transform
G = ifftshift(G);
g = ifft2(G);

% Revert back to input pixel type
g = revertclass(g);

% Crop the image to undo padding
g = g(1:dimX, 1:dimY);

figure,imshow(g, []);
title('Result Image');