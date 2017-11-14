function outImage = iCAM06_HDR(img, max_L, p, gamma_value)
% function outImage = iCAM06_HDR(img, max_L, p, gamma_value)
% iCAM06 for HDR image rendering application
% Developed by Jiangtao (Willy) Kuang
% Feb. 20, 2006
% Last updated: Aug. 6, 2007
%
% Default parameters:
% maximum luminance(cd/m2): max_L = 20,000;
% overall contrast: p = 0.7; (0.6<p<0.85); indoor scene prefer low p values 
% surround adjustment: gamma_value = 1 (for dark surround);  
%
% Examples:
% 1) with the known maximum physical luminance information max_L:
% outImage = iCAM06_HDR(img, max_L);
% 2) with unknow maximum physical luminance information, you need to guess
% one max_L, or leave it blank as:
% outImage = iCAM06_HDR(img);
% 3) the original images were stored as physical luminance data, leave
% max_L = 0, as:
% outImage = iCAM06_HDR(img, 0)
%
% gamma_value:
% average -> gamma_value = 1;
% dim -> gamma_value = 1.1; 
% dark -> gamma_value = 1.2;

tic

if nargin<2
    max_L = 20000; 
    p = 0.7;
    gamma_value = 1;
end
if nargin<3
    p = 0.7;
    gamma_value = 1; 
end
if nargin <4
    gamma_value = 1;
end

% img is an luminance RGB images with unit cd/m2
% use a sRGB matrix to convert RGB 2 XYZ
M = [0.412424    0.212656    0.0193324;  
     0.357579    0.715158    0.119193;   
     0.180464    0.0721856   0.950444];
size_img = size(img);
scalars = reshape(img, size_img(1)*size_img(2), size_img(3));
XYZpred = (scalars * M);
XYZimg = reshape(XYZpred, size_img(1), size_img(2), size_img(3));

if max_L ~= 0
    XYZimg = XYZimg/max(max(XYZimg(:,:,2)))*max_L;
end
XYZimg(find(XYZimg<0.00000001)) = 0.00000001;

clear scalars 
clear XYZpred 
clear img

% seperate Y into base-layer and detail-layer using bilateral filter
[base_img(:,:,1), detail_img(:,:,1)] = fastbilateralfilter(XYZimg(:,:,1));
[base_img(:,:,2), detail_img(:,:,2)] = fastbilateralfilter(XYZimg(:,:,2));
[base_img(:,:,3), detail_img(:,:,3)] = fastbilateralfilter(XYZimg(:,:,3));

% image chromatic adaptation
% adaptation white for the base-layer padding the edge with flipped-boader
white = iCAM06_blur(XYZimg, 2);
XYZ_adapt = iCAM06_CAT(base_img, white);

% tone compression
white = iCAM06_blur(XYZimg, 3);
clear XYZimg
% local adaptation
XYZ_tc = iCAM06_TC(XYZ_adapt, white, p);
clear XYZ_adapt
clear white

% combine the details
XYZ_d = XYZ_tc .* iCAM06_LocalContrast(detail_img, base_img);
clear XYZ_tc

% transform into IPT space and color adjustment
XYZ_p = iCAM06_IPT(XYZ_d, base_img, gamma_value);
clear XYZ_d

% invert chromatic adaptation
XYZ_tm = iCAM06_invcat(XYZ_p);
clear XYZ_p

% transform to display RGB
outImage = iCAM06_disp(XYZ_tm);
outImage = uint8(outImage);

toc
