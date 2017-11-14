function XYZ_tc = iCAM06_TC(XYZ_adapt, white_img, p)
% iCAM tone mapping based on Hunt color appearance model and CIECAM02
% written by Jiangtao (Willy) Kuang
% Feb. 20, 2006

% transform the adapted XYZ to Hunt-Pointer-Estevez space
M = [ [0.38971, 0.68898, -0.07868];...
      [-0.22981, 1.18340,  0.04641];...
      [ 0.00000, 0.00000,  1.00000] ]';
Mi = inv(M);
RGB_img = changeColorSpace(XYZ_adapt, M);

% cone response
La = 0.2*white_img(:,:,2);
k = 1./(5*La+1);
FL = 0.2*k.^4.*(5*La)+0.1*(1-k.^4).^2.*(5*La).^(1/3);

% compression
% default setting: p = .75;
sign_RGB = sign(RGB_img);
RGB_c = sign_RGB.* ((400 * (repmat(FL,[1,1,3]).*abs(RGB_img)./repmat(white_img(:,:,2),[1,1,3])).^p)./ ...
    (27.13 + (repmat(FL,[1,1,3]).*abs(RGB_img)./repmat(white_img(:,:,2),[1,1,3])).^p) ) + .1;

% make a netural As Rod response
Las = 2.26*La;
j = 0.00001./(5*Las/2.26+0.00001);
FLS = 3800*j.^2.*(5*Las/2.26)+0.2*(1-j.^2).^4.*(5*Las/2.26).^(1/6);
Sw = max(5*La(:));
S = abs(repmat(abs(XYZ_adapt(:,:,2)),[1,1,3]));
Bs = 0.5./(1+.3*((5*repmat(Las,[1,1,3])/2.26).*(S/Sw)).^3)+0.5./(1+5*(5*repmat(Las,[1,1,3])/2.26));
% Noise term in Rod response is 1/3 of that in Cone response because Rods are more sensitive
As = 3.05*Bs.*(((400 * (repmat(FLS,[1,1,3]).*(S/Sw)).^p)./ ...
    (27.13 + (repmat(FLS,[1,1,3]).*(S/Sw)).^p) )) + .03;

% combine Cone and Rod response
RGB_c = RGB_c + As;

% convert RGB_c back to XYZ space
XYZ_tc = changeColorSpace(RGB_c, Mi);

