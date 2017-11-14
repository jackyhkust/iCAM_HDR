function XYZ_p = iCAM06_IPT(XYZ_img, base_img, gamma)
% transform into IPT and post-processing
% written by Jiangtao (Willy) Kuang
% Feb. 22, 2006

% transform into IPT space
xyz2lms = cmatrix('xyz2lms');
iptMat = [[ 0.4000, 0.4000, 0.2000];...
    [ 4.4550,-4.8510, 0.3960];...
    [ 0.8056, 0.3572,-1.1628] ]';

% convert to LMS space
lms_img = changeColorSpace(XYZ_img, xyz2lms);

% apply the IPT exponent
ipt_img = changeColorSpace(abs(lms_img).^.43, iptMat);
c = sqrt(ipt_img(:,:,2).^2+ipt_img(:,:,3).^2);

% colorfulness adjustment - Hunt effect
La = 0.2*base_img(:,:,2);
k = 1./(5*La+1);
FL = 0.2*k.^4.*(5*La)+0.1*(1-k.^4).^2.*(5*La).^(1/3);   
ipt_img(:,:,2) = ipt_img(:,:,2).*((FL+1).^.15.*((1.29*c.^2-0.27*c+0.42)./(c.^2-0.31*c+0.42)));
ipt_img(:,:,3) = ipt_img(:,:,3).*((FL+1).^.15.*((1.29*c.^2-0.27*c+0.42)./(c.^2-0.31*c+0.42))); 
% to turn off the details enhancement, comment two lines above and uncomment two lines below 
% ipt_img(:,:,2) = ipt_img(:,:,2);
% ipt_img(:,:,3) = ipt_img(:,:,3); 

% Bartleson surround adjustment
max_i = max(max(ipt_img(:,:,1)));
ipt_img(:,:,1) = ipt_img(:,:,1)/max_i;
ipt_img(:,:,1) = ipt_img(:,:,1).^(gamma);
ipt_img(:,:,1) = ipt_img(:,:,1)*max_i;

% inverse IPT 
lms_img = changeColorSpace( ipt_img, inv(iptMat) );
XYZ_p = changeColorSpace(abs(lms_img).^(1/.43), inv(xyz2lms));


