function XYZ_adapt = iCAM06_CAT(XYZimg, white)
% iCAM color chromatic adaptation
% use CIECAM02 CAT here
% written by Willy Kuang
% Feb. 20, 2006

% First things first...define the XYZ to RGB transform
M = [ [0.7328,  0.4296, -0.1624];...
      [-0.7036, 1.6974,  0.0061];...
      [ 0.0030, 0.0136,  0.9834] ]';
Mi = inv(M);
RGB_img = changeColorSpace(XYZimg, M);

RGB_white = changeColorSpace(white, M);
xyz_d65 = [ 95.05,  100.0, 108.88]; 
RGB_d65 = changeColorSpace(xyz_d65, M );

La = 0.2*white(:,:,2);
% % CIECAM02 CAT
% % suppose it is in an average surround
F = 1;
% default setting for 30% incomplete chromatic adaptation: a = 0.3
D = 0.3*F*(1-(1/3.6)*exp(-1*(La-42)/92));

RGB_white = RGB_white+0.0000001; 
Rc = (D .* RGB_d65(1)./RGB_white(:,:,1) + 1 - D) .* RGB_img(:,:,1);
Gc = (D .* RGB_d65(2)./ RGB_white(:,:,2) + 1 - D) .* RGB_img(:,:,2);
Bc = (D .* RGB_d65(3)./ RGB_white(:,:,3) + 1 - D) .* RGB_img(:,:,3);

adaptImage(:,:,1) = Rc;
adaptImage(:,:,2) = Gc;
adaptImage(:,:,3) = Bc;	
XYZ_adapt = changeColorSpace(adaptImage, Mi);


