%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Simple Gamma Compression for tone mapping
function [image] = toneMapGamma(radMap, gamma)
% compress
image = radMap .^ gamma;

% normalize
maxVal = max(max(max(image)));
image = image ./ maxVal;

end