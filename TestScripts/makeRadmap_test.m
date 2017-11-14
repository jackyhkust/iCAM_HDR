%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Script to test radiance map creation (may need tweaks to run on your setup)
addpath(genpath('../')) % added to work with new directory structure

%% Input
expTimes = 1 ./ load('TestImages/Test1-ExpTime.txt');
imgFiles = {'TestImages/Test1-1.jpg', 'TestImages/Test1-2.jpg', 'TestImages/Test1-3.jpg', 'TestImages/Test1-4.jpg', 'TestImages/Test1-5.jpg'};
%% Function calls
imgs = loadImages(imgFiles);
radmap = makeRadmap(imgs,expTimes,20);
%% Write to file
%hdrwrite(radmap,'TestImages/Test1.hdr');

rmpath(genpath('../'))