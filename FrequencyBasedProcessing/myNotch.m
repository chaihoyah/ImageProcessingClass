input=imread('cat-halftone.png');

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
n = 3;
D0 = 100;
k0 = [dimPadX*37/120, dimPadY*37/120];
k1 = [dimPadX*37/120, 0];
k2 = [dimPadX*37/120, -1*dimPadY*37/120];
k3 = [0, dimPadY*37/120];

D = double(zeros(dimPadX,dimPadY));
D_minus = double(zeros(dimPadX,dimPadY));
D1 = double(zeros(dimPadX,dimPadY));
D1_minus = double(zeros(dimPadX,dimPadY));
D2 = double(zeros(dimPadX,dimPadY));
D2_minus = double(zeros(dimPadX,dimPadY));
D3 = double(zeros(dimPadX,dimPadY));
D3_minus = double(zeros(dimPadX,dimPadY));
for i=1:dimPadX
    for j=1:dimPadY
        D(i,j) = ((i-dimPadX/2-k0(1))^2+(j-dimPadY/2-k0(2))^2)^(1/2);
        D_minus(i,j) = ((i-dimPadX/2+k0(1))^2+(j-dimPadY/2+k0(2))^2)^(1/2);
        D1(i,j) = ((i-dimPadX/2-k1(1))^2+(j-dimPadY/2-k1(2))^2)^(1/2);
        D1_minus(i,j) = ((i-dimPadX/2+k1(1))^2+(j-dimPadY/2+k1(2))^2)^(1/2);
        D2(i,j) = ((i-dimPadX/2-k2(1))^2+(j-dimPadY/2-k2(2))^2)^(1/2);
        D2_minus(i,j) = ((i-dimPadX/2+k2(1))^2+(j-dimPadY/2+k2(2))^2)^(1/2);
        D3(i,j) = ((i-dimPadX/2-k3(1))^2+(j-dimPadY/2-k3(2))^2)^(1/2);
        D3_minus(i,j) = ((i-dimPadX/2+k3(1))^2+(j-dimPadY/2+k3(2))^2)^(1/2);
    end
end
H0 = (1.-(1./(1+(D./D0).^(2*n)))).*(1.-(1./(1+(D_minus./D0).^(2*n))));
H1 = (1.-(1./(1+(D1./D0).^(2*n)))).*(1.-(1./(1+(D1_minus./D0).^(2*n))));
H2 = (1.-(1./(1+(D2./D0).^(2*n)))).*(1.-(1./(1+(D2_minus./D0).^(2*n))));
H3 = (1.-(1./(1+(D3./D0).^(2*n)))).*(1.-(1./(1+(D3_minus./D0).^(2*n))));
H = H0.*H1.*H2.*H3;
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