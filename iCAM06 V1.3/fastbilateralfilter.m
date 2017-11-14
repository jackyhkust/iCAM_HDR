function [base_layer, detail_layer] = fastbilateralfilter(img)
% seperate image into base-layer and detail layer
% bilateral filter
% written by Jiangtao (Willy) Kuang and Hiroshi Yamaguchi
% Feb. 20, 2006

if min(size(img))<1024 
    z = 2;
else
    z = 4;
end

img(find(img(:)<0.0001))=0.0001;
logimg = log10(img);
base_layer = PiecewiseBilateralFilter(logimg, z);
% remove error points if any
base_layer = min(base_layer, max(logimg(:)));
detail_layer = logimg - base_layer;
detail_layer(find(detail_layer(:)>12)) = 0;
base_layer = 10.^base_layer;
detail_layer = 10.^detail_layer;



function imageOut = PiecewiseBilateralFilter(imageIn, z)

%Get size info.
imSize = size(imageIn);
xDim = imSize(2);
yDim = imSize(1);
%Parameters
%Keep sigma_s constant to a value of 2% of the image size
sigma_s=2*xDim/z/100;  
%The value sigma_r=0.35 performed consistently well for all their exp.
sigma_r=0.35;
%Max Min
maxI=max(imageIn(:));  
minI=min(imageIn(:));
nSeg=(maxI-minI)/sigma_r;
inSeg=round(nSeg);

%Create Gaussian Kernel
distMap = idl_dist(yDim,xDim);
kernel = exp(-1*(distMap./sigma_s).^2);
kernel = kernel/kernel(1,1);
fs = max(real(fft2(kernel)),0);
fs = fs./fs(1,1);

% downsampling
Ip = imageIn(1:z:end,1:z:end);
fsp = fs(1:z:end,1:z:end);

%Set the output to zero
imageOut=zeros(size(imageIn));
jGp=zeros(size(Ip));
jKp=zeros(size(Ip));
intW=zeros(size(imageIn));   %Interpolation Weight map
for j=0:1:inSeg
    value_i=minI+j*(maxI-minI)/inSeg;
    %edge-stopping function
    jGp=exp((-1/2)*((Ip-value_i)./sigma_r).^2);
    %normalization factor
    jKp= max( real(ifft2(fft2(jGp(:,:)).*fsp)), 0.0000000001); 
    %Compute H for each pixel
    jHp=jGp.*Ip;
    sjHp=real(ifft2(fft2(jHp(:,:)).*fsp));
    %normalize
    jJp=sjHp./jKp;
    
    % upsampling
    jJ = imresize(jJp, z, 'nearest');
    jJ = jJ(1:yDim,1:xDim);
    %interpolation
    intW =max( ones(size(imageIn))-abs(imageIn-value_i)*(inSeg)/(maxI-minI),0);
    %%%%%%%%%%%%%%%%
    imageOut(:,:)=imageOut(:,:)+jJ(:,:).*intW(:,:);
end

