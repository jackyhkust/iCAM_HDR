function imgIPT = iCam_hdr(imageIn)

% written by: Lawrence Taplin and Garrett M. Johnson
%
% The function essentially performs the "meat" of the iCAM
% HDR tone mapping. It is given an XYZ image as the input
% and returns an IPT image as the output
%
% Modified: 01/31/02


% get the adaptation "whitepoint," which is a blurred version
% of the image

imSize = size(imageIn);
xDim = imSize(2);
yDim = imSize(1);

%distMap = dist(xDim, yDim);
distMap = idl_dist(yDim,xDim);

kernel = exp(-1*(distMap./(xDim/4)).^2);

% since we are convolving, normalize the kernel to sum
% to 1, and shift it to the center


% kernel = shift(kernel, xDim/2, xDim/2)/total(kernel)

filter = max(real(fft2(kernel)),0);
filter = filter./filter(1,1);

% kernel = kernel/kernel[0,0]
whiteXYZ = zeros(size(imageIn));

%whiteXYZ[0,*,*] = convol(reform(image[1,*,*]), kernel, /center, /edge_wrap)

whiteXYZ(:,:,1) = max(real(ifft2(fft2(imageIn(:,:,2)).*filter)),0);
whiteXYZ(:,:,2) = whiteXYZ(:,:,1);
whiteXYZ(:,:,3) = whiteXYZ(:,:,1);

% figure;
% imagesc(whiteXYZ);


%surface, kernel
%tvscl, whiteXYZ, /true
% perform the HDR hromatic adaptation transform
imgCAT = cat_hdr(imageIn, whiteXYZ);

%imgCAT = image

% transform into the IPT color space, blurred appropriately
imgIPT = ipt_hdr(imgCAT, squeeze(imageIn(:,:,2)));

