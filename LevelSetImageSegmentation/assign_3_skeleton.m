%
% Skeleton code for COSE490 Fall 2020 Assignment 3
%
% Won-Ki Jeong (wkjeong@korea.ac.kr)
%

clear all;
close all;

%
% Loading input image
%
Img=imread('coins-small.bmp');
Img=double(Img(:,:,1));

%
% Parameter setting
%
dt = 0.8;  % time step
c = 1.0;  % weight for expanding term
niter = 400;


%
% Initializing distance field phi
%
% Inner region : -1, Outer region : +1, Contour : 0
%
[numRows,numCols] = size(Img);
phi=ones(size(Img));
phi(10:numRows-10, 10:numCols-10)=-1;

%
% Compute g (edge indicator, computed only once)
%

% ToDO ------------------------
% Using LPF implemented in Assignment 2
dimX = size(Img,1);
dimY = size(Img,2);

PQ = size(Img)*2;
dimPadX = PQ(1);
dimPadY = PQ(2);

F = fft2(Img,PQ(1),PQ(2));
F = fftshift(F);

n = 2;
D0 = 70;
D = double(zeros(dimPadX,dimPadY));
for i=1:dimPadX
    for j=1:dimPadY
        D(i,j) = ((i-dimPadX/2)^2+(j-dimPadY/2)^2)^(1/2);
    end
end

H = 1./(1+(D./D0).^(2*n));
G = H.*F;
G = ifftshift(G);
I_hat = ifft2(G);
I_hat = real(I_hat(1:dimX, 1:dimY));
figure,imshow(I_hat, []);
title('Smoothed Image');

%find gradient and corresponding g term
[dim_Ix,dim_Iy] = size(I_hat);
dx=zeros(dim_Ix,dim_Iy);
dy=zeros(dim_Ix,dim_Iy);

for x=2:dimX-1
    for y=2:dimY-1
        dx(x,y) = (I_hat(x+1,y+1)+2.*I_hat(x+1,y)+I_hat(x+1,y-1)-2.*I_hat(x-1,y)-I_hat(x-1,y+1)-I_hat(x-1,y-1))./9;
        dy(x,y) = (I_hat(x-1,y+1)+2.*I_hat(x,y+1)+I_hat(x+1,y+1)-I_hat(x-1,y-1)-2.*I_hat(x,y-1)-I_hat(x+1,y-1))./9;
    end
end

tmp = sqrt(dx.^2+dy.^2);
p = 2;
g = 1./(1+tmp.^p);

% -----------------------------

%
% Level set iteration
%
for n=1:niter
    
    %
    % Level set update function
    %
    phi = levelset_update(phi, g, c, dt);    

    %
    % Display current level set once every k iterations
    %
    k = 10;
    if mod(n,k)==0
        figure(1);
        imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on; contour(phi, [0,0], 'r');
        str=['Iteration : ', num2str(n)];
        title(str);
        
    end
end


%
% Output result
%
figure(1);
imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
str=['Final level set after ', num2str(niter), ' iterations'];
title(str);

