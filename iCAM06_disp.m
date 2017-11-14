function outImage = iCAM06_disp(XYZ_tm)
% invert XYZ to display RGB
% written by Jiangtao (Willy) Kuang
% Feb. 22, 2006

str = computer;
if strcmp(str, 'PCWIN')
    % sRGB Output
    % For general PC user (Uncomment this part)
    XYZ_tm = XYZ_tm/max(max(XYZ_tm(:,:,2)));
    M = [3.2407   -0.9693    0.0556;
         -1.5373    1.8760   -0.2040;
         -0.4986    0.0416    1.0571];
    RGB = changeColorSpace(XYZ_tm, M);
    % Clipping: simulate incomplete light adaptation and the glare in visual system
    % clip 1% dark pixels and light pixels individually    
    min_rgb = max(percentile(RGB(:),1),0);
    max_rgb = percentile(RGB(:),99);   
    RGB = (RGB - min_rgb) ./ (max_rgb - min_rgb);   
    RGB = min(RGB,1);        
    RGB = max(RGB,0);
    % normalization
    sRGB = (RGB<-0.0031308).*((-1.055)*(-1*RGB).^(1/2.4)+.055)+...
           ((RGB>=-0.0031308) & (RGB<=0.0031308)).*RGB*12.92+...
           (RGB>0.0031308).*(RGB.^(1/2.4)*1.055-0.055);
    outImage = uint8(sRGB*255);
else
    % Apple HD Cinema Display Profile
    % For general Mac user (Uncomment this part)
    % LCD display inverse model
    lcd = load('lcd_fechner2.mat');
    lcd_parameters = lcd.lcd_parameters2;
    w = ([1 1 1] * (lcd_parameters.primaries)');    % white point
    lcd_Y = w(2);
    k = lcd_Y/max(max(XYZ_tm(:,:,2)));
    XYZ_tm = XYZ_tm*k;
    yDim = size(XYZ_tm,1);
    xDim = size(XYZ_tm,2);
    XYZ = zeros(3,yDim*xDim);
    XYZ(1,:) = reshape(XYZ_tm(:,:,1), 1, []);
    XYZ(2,:) = reshape(XYZ_tm(:,:,2), 1, []);
    XYZ(3,:) = reshape(XYZ_tm(:,:,3), 1, []);

    % compute scalars, clip to 0->1 range and flag out of gamut
    scalars = inv(lcd_parameters.primaries) * XYZ;
    scalars = max(scalars,0);

    % Clipping: simulate incomplete light adaptation and the glare in visual system
    % clip 1% dark pixels and light pixels individually
    min_rgb = max(percentile(scalars(:),1),0);
    max_rgb = percentile(scalars(:),99);

    debugimg = (scalars - min_rgb) ./ (max_rgb - min_rgb);
    debugimg = max(debugimg,0);
    debugimg = min(debugimg,1);
    scalars = debugimg;

    % create inverse lut if necessary
    if ~isfield(lcd_parameters,'invLUT')
        lcd_parameters.invLUT = zeros(3,1000);
        lcd_parameters.LUT(:,end) = 1;
        for i=1:3
            lcd_parameters.invLUT(i,:) =  round(interp1(lcd_parameters.LUT(i,:), 0:255, linspace(0,1,1000), 'linear', 0));    
        end
        lcd_parameters.invLUT(:,1000) =  255;
    end

    % pull values from inverse lookup table
    DCout = round(scalars*999)+1;
    for i=1:3
        DCout(i,:) = lcd_parameters.invLUT(i,DCout(i,:));
    end

    outImage = zeros(size(XYZ_tm));
    outImage(:,:,1) = reshape(DCout(1,:),yDim,xDim);
    outImage(:,:,2) = reshape(DCout(2,:),yDim,xDim);
    outImage(:,:,3) = reshape(DCout(3,:),yDim,xDim);
end


function y = percentile(x,p)
% Percentiles of a sample.
% x is a vector, and p is a scalar 

n = length(x); 
x = sort(x,1);
q = [0 100*(0.5:(n-0.5))./n 100]';
xx = [x(1); x(1:n); x(n)];
y = interp1q(q,xx,p);
