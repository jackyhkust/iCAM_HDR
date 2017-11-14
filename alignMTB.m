%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% MTB Alignment
% Implementation of "Fast, Robust Image Registration for Compositing High Dynamic Range Photographs from Handheld Exposures"
function alignedImgs = alignMTB(imgs, offsetRange)
% parameters
height = size(imgs, 1);
width = size(imgs, 2);
nImgs = size(imgs, 4);
nLevels = floor(log2(offsetRange * min(height, width)));
% align all images
alignedImgs = zeros(size(imgs),'uint8');
alignedImgs(:,:,:,1) = imgs(:,:,:,1);
offsets = zeros(nImgs, 2);
for i = 2:nImgs
    offsets(i,:) = getExpShift(imgs(:,:,2,i-1), imgs(:,:,2,i), nLevels);
    offsets(i,:) = offsets(i,:) + offsets(i-1,:);
    alignedImgs(:,:,:,i) = imtranslate(imgs(:,:,:,i), offsets(i,:));
end
end

%% Get the shift offsets to align img2 with img1
function shift_ret = getExpShift(img1, img2, shift_bits)
% recursive calls
if shift_bits > 0
    sml_img1 = impyramid(img1, 'reduce');
    sml_img2 = impyramid(img2, 'reduce');
    cur_shift = getExpShift(sml_img1, sml_img2, shift_bits - 1);
    cur_shift = cur_shift * 2;
else
    cur_shift = [0 0];
end
% compute threshold and exclusion bitmaps
[tb1, eb1] = computeBitmaps(img1);
[tb2, eb2] = computeBitmaps(img2);
% find an offset that minimizes error
min_err = size(img1, 1) * size(img2, 2);
for i = -1:1
    for j = -1:1
        xs = cur_shift(1) + i;
        ys = cur_shift(2) + j;
        shifted_tb2 = imtranslate(tb2, [xs ys]);
        shifted_eb2 = imtranslate(eb2, [xs ys]);
        diff_b = xor(tb1, shifted_tb2) & eb1 & shifted_eb2;
        err = nnz(diff_b);
        if err < min_err
            shift_ret = [xs ys];
            min_err = err;
        end
    end
end
end

%% Compute the threshold bitmap tb and the exclusion bitmap eb for the image img
function [tb, eb] = computeBitmaps(img)
med_val = median(img(:));
tb = img > med_val;
eb = (img < med_val - 4) | (img > med_val + 4);
end
