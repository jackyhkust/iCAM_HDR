%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Script to test alignment (may need tweaks to run on your setup)
addpath(genpath('../')) % added to work with new directory structure

%% Input
imgFiles = {'TestImages/Test3-1.jpg', 'TestImages/Test3-2.jpg', 'TestImages/Test3-3.jpg', 'TestImages/Test3-4.jpg'};
%% Function call
imgs = loadImages(imgFiles);
alignedImgs = alignMTB(imgs, 0.2);
%% Show Results
nImgs = size(imgs,4);
img = zeros(size(imgs,1),size(imgs,2),3,'uint8');
alignedImg = zeros(size(imgs,1),size(imgs,2),3,'uint8');;
for i=1:nImgs
    img = img + imgs(:,:,:,i) / nImgs;
    alignedImg = alignedImg + alignedImgs(:,:,:,i) / nImgs;
end
figure;
imshow(img);
figure;
imshow(alignedImg);
%% Save Images
%imwrite(alignedImgs(:,:,:,1), 'TestImages/Test3-1-Aligned.jpg','jpg');
%imwrite(alignedImgs(:,:,:,2), 'TestImages/Test3-2-Aligned.jpg','jpg');
%imwrite(alignedImgs(:,:,:,3), 'TestImages/Test3-3-Aligned.jpg','jpg');
%imwrite(alignedImgs(:,:,:,4), 'TestImages/Test3-4-Aligned.jpg','jpg');

rmpath(genpath('../'))