function ipt_image = ipt_hdr(xyz_image, Yimage)

% Written by: Garrett M. Johnson
%
% This function performs the IPT transform
% Specifically for the HDR iCAM model. Essentiall
% It creates a low-pass image mask based on the Y 
% channel, and uses the CIECAM02 surround formula
% to modify the IPT exponent
%
% Modified 02/02/03
%


imSize = size(xyz_image);
xDim = imSize(2);
yDim = imSize(1);

distMap = idl_dist(yDim, xDim);


% The kernel is a Gaussian function of width 
% xDimension/3.0
%
kernel = exp(-1 * (distMap/(xDim/1)).^2); 
kernel = kernel/kernel(1,1);


% Tranform Gaussian to Frequency domain, and normalize
% the DC component
filter = max(real(fft2(kernel)), 0);
filter = filter/filter(1,1);

% Filter the image
yLow = max(real(ifft2(fft2(Yimage).*filter)),0);


iptMat = [[ 0.4000, 0.4000, 0.2000];...
    [ 4.4550,-4.8510, 0.3960];...
    [ 0.8056, 0.3572,-1.1628] ]';

xyz2lms = cmatrix('xyz2lms');

lms_image = changeColorSpace(xyz_image/100.0, xyz2lms);


% the exponent scale is calculated based on the surround
% function from CIECAM02. It is set to 1.0 for a value
% of 100.0
exp_scale = (1/1.7) * (0.2 * (1./(5*yLow + 1)).^4 .* (5*yLow) + 0.1*(1-(1./(5*yLow+1)).^4).^2 .* (5*yLow).^(1/3));


lms_nl = lms_image;


% apply the IPT exponent along with the scaling factor
lms_nl(:,:,1) = abs(lms_image(:,:,1)).^(exp_scale*.43);
lms_nl(:,:,2) = abs(lms_image(:,:,2)).^(exp_scale*.43);
lms_nl(:,:,3) = abs(lms_image(:,:,3)).^(exp_scale*.43);


ipt_image = changeColorSpace(lms_nl, iptMat);
