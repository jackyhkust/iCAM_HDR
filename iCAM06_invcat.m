function XYZ_adapt = iCAM06_invcat(XYZ_img)
% invert chromatic adaptation to display's white
% written by Jiangtao (Willy) Kuang
% Feb. 22, 2006

% First things first...define the XYZ to RGB transform again using the CIECAM02 transform
M = [ [ 0.8562,  0.3372, -0.1934];...
        [-0.8360,  1.8327,  0.0033];...
        [ 0.0357, -0.0469,  1.0112] ]';

Mi = inv(M);

xyz_d65 = [ 95.05,  100.0, 108.88]; 
RGB_d65 = changeColorSpace(xyz_d65, M );

str = computer;
if strcmp(str, 'PCWIN')
    % sRGB Output
    % For general PC user (Uncomment this part)
    whitepoint = [ 95.05,  100.0, 108.88];
else
    % Apple HD Cinema Display Profile
    % For general Mac user (Uncomment this part)
    lcd = load('lcd_fechner2.mat');
    lcd_parameters = lcd.lcd_parameters2;
    whitepoint = ([1 1 1] * (lcd_parameters.primaries)');    % white point
end

RGB_white = changeColorSpace(whitepoint, M);
RGB_img = changeColorSpace(XYZ_img, M);


% we want to use a complete adaptation transform, so
% keep D set to 1.0, and don't try to calculate it
D = 1;

Rc = (D * RGB_white(1) ./ RGB_d65(1) + 1 - D) .* RGB_img(:,:,1);
Gc = (D * RGB_white(2) ./ RGB_d65(2) + 1 - D) .* RGB_img(:,:,2);
Bc = (D * RGB_white(3) ./ RGB_d65(3) + 1 - D) .* RGB_img(:,:,3);

adaptImage(:,:,1) = Rc;
adaptImage(:,:,2) = Gc;
adaptImage(:,:,3) = Bc;	

XYZ_adapt = changeColorSpace(adaptImage, Mi);
