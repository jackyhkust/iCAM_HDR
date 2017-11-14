%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Simple function to load a list of images
function imgs = loadImages(imgFiles)
imgNum = length(imgFiles);
imgInfo = imfinfo(char(imgFiles(1)));
height = imgInfo.Height;
width = imgInfo.Width;
imgs = zeros(height,width,3,imgNum,'uint8');
for i=1:imgNum
    imgs(:,:,:,i) = imread(char(imgFiles(i)));
end
end

