function white = iCAM06_blur(img, d)
% generate low-pass version of the base image as adapted white
% written by Jiangtao (Willy) Kuang
% Feb. 22, 2006

% downsampling
[sy,sx,sz] = size(img);
m = min(sy,sx);
if m<64
    z = 1;
elseif m<256
    z = 2;
elseif m<512
    z = 4;
elseif m<1024
    z = 8;
elseif m<2056
    z = 16;
else
    z = 32;
end
img = img(1:z:end,1:z:end,:);

imSize = size(img);
xDim = imSize(2);
yDim = imSize(1);

% padding
Y                          = zeros(2*yDim, 2*xDim,3);
Y(fix(yDim/2)+1:fix(yDim/2)+yDim,fix(xDim/2)+1:fix(xDim/2)+xDim,:) = img; 
Y(fix(yDim/2)+1:fix(yDim/2)+yDim,fix(xDim/2):-1:1,:) = img(:,1:fix(xDim/2),:);
Y(fix(yDim/2)+1:fix(yDim/2)+yDim,fix(xDim/2)+xDim+1:2*xDim,:) = img(:,xDim:-1:fix(xDim/2)+1,:);
Y(fix(yDim/2):-1:1,fix(xDim/2)+1:fix(xDim/2)+xDim,:) = img(1:fix(yDim/2),:,:);
Y(fix(yDim/2)+1+yDim:2*yDim,fix(xDim/2)+1:fix(xDim/2)+xDim,:) = img(yDim:-1:fix(yDim/2)+1,:,:);

Y(1:fix(yDim/2),1:fix(xDim/2),:) = img(fix(yDim/2):-1:1,fix(xDim/2):-1:1,:);
Y(1:fix(yDim/2),2*xDim:-1:fix(xDim/2)+xDim+1,:) = img(fix(yDim/2):-1:1,fix(xDim/2)+1:xDim,:);
Y(2*yDim:-1:fix(yDim/2)+1+yDim, 2*xDim:-1:fix(xDim/2)+1+xDim,:) = img(fix(yDim/2)+1:yDim,fix(xDim/2)+1:xDim,:);
Y(2*yDim:-1:fix(yDim/2)+1+yDim, fix(xDim/2):-1:1,:) = img(fix(yDim/2)+1:yDim,1:fix(xDim/2),:);

clear img

distMap = idl_dist(size(Y,1),size(Y,2));
% Gaussian filter
Dim = max(xDim, yDim);
kernel = exp(-1*(distMap./(Dim/d)).^2);
clear distMap
% since we are convolving, normalize the kernel to sum
% to 1, and shift it to the center
filter = max(real(fft2(kernel)),0);
filter = filter./filter(1,1);   
clear kernel


white(:,:,1) = max(real(ifft2(fft2(Y(:,:,1)).*filter)),0);
white(:,:,2) = max(real(ifft2(fft2(Y(:,:,2)).*filter)),0);
white(:,:,3) = max(real(ifft2(fft2(Y(:,:,3)).*filter)),0);
white = white(fix(yDim/2)+1:fix(yDim/2)+yDim,fix(xDim/2)+1:fix(xDim/2)+xDim,:);


% upsampling
white = imresize(white, z, 'nearest');
white = white(1:sy,1:sx,:);
