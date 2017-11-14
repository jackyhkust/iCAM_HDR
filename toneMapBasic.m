%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Reinhard basic (global operator) tone mapping
% Input: radMap - hdr image; a - tuning paramter
function [image] = toneMapBasic(radMap, a)
d = 0.000001; % to correct for log(0)
N = size(radMap,1) * size(radMap,2);

% scale
sums = sum(sum( log(d + radMap) )) ./ N;
Lw_bar = exp(sums);
coeff = a ./ Lw_bar;
image(:,:,1) = coeff(1) .* radMap(:,:,1);
image(:,:,2) = coeff(2) .* radMap(:,:,2);
image(:,:,3) = coeff(3) .* radMap(:,:,3);

% map
image(:,:,1) = image(:,:,1) ./ (1 + image(:,:,1));
image(:,:,2) = image(:,:,2) ./ (1 + image(:,:,2));
image(:,:,3) = image(:,:,3) ./ (1 + image(:,:,3));

end