%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Implementation of Drago et al. tone mapping algorithm!
% Adaptive Logarithmic Mapping For Displaying High Contrast Scenes
% http://pages.cs.wisc.edu/~lizhang/courses/cs766-2012f/projects/hdr/Drago2003ALM.pdf
% BONUS!
%
% Note: Slower, but vivid recreation
%
% Input: radMap - the RGB radiance map; b - the bias parameter (0.85 works best typically)
% Output: image - the Low Dynamic Range, toned-mapped RGB image
%
function [image] = toneMapDrago(radMap, b)
%convert to Yxy color space

% arbitrary rgb to xyz conversion
xyz(:,:,1) = 0.412453 .* radMap(:,:,1) + 0.357580 .* radMap(:,:,2) + 0.180423 .* radMap(:,:,3);
xyz(:,:,2) = 0.212671 .* radMap(:,:,1) + 0.715160 .* radMap(:,:,2) + 0.072169 .* radMap(:,:,3);
xyz(:,:,3) = 0.019334 .* radMap(:,:,1) + 0.119193 .* radMap(:,:,2) + 0.950227 .* radMap(:,:,3);

% convert to Yxy
W = sum(xyz,3);
Yxy(:,:,1) = xyz(:,:,2);     % Y
Yxy(:,:,2) = xyz(:,:,1) ./ W;	% x
Yxy(:,:,3) = xyz(:,:,2) ./ W;	% y

% run global operator
N = numel(Yxy(:,:,1));
maxLum = max(max(Yxy(:,:,1)));

logSum = sum(log(reshape(Yxy(:,:,1), [1 N] )));
logAvgLum = logSum / N;
avgLum = exp(logAvgLum);
maxLumW = (maxLum / avgLum);

%replace luminance values
coeff = (100 * 0.01) / log10(maxLumW + 1);
Yxy(:,:,1) = Yxy(:,:,1) ./ avgLum;
Yxy(:,:,1) = ( log(Yxy(:,:,1) + 1) ./ log(2 + bias((Yxy(:,:,1) ./ maxLumW), b) .* 8) ) .* coeff;

% convert back to RGB

% Yxy to xyz
newW = Yxy(:,:,1) ./ Yxy(:,:,3);
xyz(:,:,2) = Yxy(:,:,1);
xyz(:,:,1) = newW .* Yxy(:,:,2);
xyz(:,:,3) = newW -xyz(:,:,1) - xyz(:,:,2);

% arbitrary xyz to rgb conversion
image(:,:,1) = 3.240479 .* xyz(:,:,1) + -1.537150 .* xyz(:,:,2) + -0.498535 .* xyz(:,:,3);
image(:,:,2) = -0.969256 .* xyz(:,:,1) + 1.875992 .* xyz(:,:,2) + 0.041556 .* xyz(:,:,3);
image(:,:,3) = 0.055648 .* xyz(:,:,1) + -0.204043 .* xyz(:,:,2) + 1.057311 .* xyz(:,:,3);

% correct gamma
image = fixGamma(image, 2.7);
end

% Bias power function
function [bT] = bias(t ,b)
bT = t .^ ( log(b) / log(0.5) );
end

%% fix gamma based on paper method (nasty but it works well)
function [image] = fixGamma(oldImage, gamma)
slope = 4.5;
start = 0.018;
fgamma = (0.45/gamma)*2;

if gamma >= 2.1
    start = 0.018 / ((gamma - 2) * 7.5);
    slope = 4.5 * ((gamma - 2) * 7.5);
elseif gamma <= 1.9
    start = 0.018 * ((2 - gamma) * 7.5);
    slope = 4.5 / ((2 - gamma) * 7.5);
end

image = nan(size(oldImage));

for row = 1:size(oldImage,1)
    for col = 1:size(oldImage,2)
        %red
        if oldImage(row,col,1) <= start
            image(row,col,1) = oldImage(row,col,1) * slope;
        else
            image(row,col,1) = 1.099 * power(oldImage(row,col,1), fgamma) - 0.099;
        end
        
        %green
        if oldImage(row,col,2) <= start
            image(row,col,2) = oldImage(row,col,2) * slope;
        else
            image(row,col,2) = 1.099 * power(oldImage(row,col,2), fgamma) - 0.099;
        end
        
        %blue
        if oldImage(row,col,3) <= start
            image(row,col,3) = oldImage(row,col,3) * slope;
        else
            image(row,col,3) = 1.099 * power(oldImage(row,col,3), fgamma) - 0.099;
        end
        
    end
end
end