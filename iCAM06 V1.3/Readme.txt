iCAM06 for HDR image Rendering

Last updated: August 6, 2007

www.cis.rit.edu/mcsl/icam06
If you have any question, or if you find any bug, please contact Jiangtao Kuang (jkuang@ovt.com), or Mark Fairchild (mdf@cis.rit.edu). 
-------------------------------------------------------------------

Reference: 
Jiangtao Kuang, Garrett M. Johnson, Mark D. Fairchild, Kuang, J., Johnson, G.M., Fairchild M.D., iCAM06: A refined image appearance model for HDR imagerendering, Journal of Visual Communication, 2007. 
-------------------------------------------------------------------

& How to use this algorithm? 
  Example:

image = read_radiance('PeckLake.hdr');
outImage = iCAM06_HDR(image, 20000, 0.7, 1);
---------------------------------------------------------------------

& Main function settings:

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
------------------------------------------------------------------------

& Software requirements: Matlab with image processing toolbox.
-------------------------------------------------------------------------

& Note: the output precedure depends on the output media and viewing conditions. The codes detect PC or Mac machine automatically, and use sRGB and a Apple HD Cinema LCD display profile respectively as default. If you have a unique display profile, you can change the codes. This influences "iCAM06_invcat.m" and "iCAM06_disp.m".

 


