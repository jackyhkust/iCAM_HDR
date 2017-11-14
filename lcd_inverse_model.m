% lcd_inverse model - inverse model for lcd characterization
%                   - takes XYZ in and outputs normalized digital counts
%
% LAT Aug-05-2003

function [DCout, outofgamut] = lcd_inverse_model(XYZin, lcd_parameters)

% subtract flare from XYZ data
XYZin = XYZin - repmat(lcd_parameters.flare,1,size(XYZin,2));

% compute scalars, clip to 0->1 range and flag out of gamut
scalars = inv(lcd_parameters.primaries) * XYZin;
outofgamut = scalars<0 | scalars>1;
scalars = max(min(scalars,1),0);

% create inverse lut if necessary
if ~isfield(lcd_parameters,'invLUT')
    lcd_parameters.invLUT = zeros(3,1000);
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