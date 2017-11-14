%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Script to test merging several exposures (may need tweaks to run on your setup)
addpath(genpath('../')) % added to work with new directory structure

%% Construct radiance map
E = mergeExps(gImgs,B,g,w);
%% Display radiance map in false color
figure;
imshow(E,[],'Colormap',jet(256));
colorbar;
%% Simple gamma correction
gamma = 0.025;
newImg = power(E,gamma);
figure;
imshow(newImg,[]);

rmpath(genpath('../'))