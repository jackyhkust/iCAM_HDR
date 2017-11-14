%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Durand Tone-mapping
% Implementation of "Fast Bilateral Filtering for the Display of High-Dynamic-Range Images"
%
% Input "radmap" must be of type double!
function image = toneMapDurand(radmap, contrast)
Imap = (radmap(:,:,1) * 20 + radmap(:,:,2) * 40 + radmap(:,:,3) * 1) / 61;
Rmap = radmap(:,:,1) ./ Imap;
Gmap = radmap(:,:,2) ./ Imap;
Bmap = radmap(:,:,3) ./ Imap;
lImap = log10(Imap);
lBase = bilateral(lImap, min(size(lImap,1),size(lImap,2))*0.02, 0.4);
lDetail = lImap - lBase;
maxVal = max(max(lBase));
minVal = min(min(lBase));
gamma = log10(contrast) / (maxVal - minVal);
%Offset = max(max(lBase)) * Scale;
%lOmap = lBase * Scale + lDetail - Offset;
lOmap = lBase * gamma + lDetail;
Omap = 10 .^ lOmap;
image(:,:,1) = Omap .* Rmap;
image(:,:,2) = Omap .* Gmap;
image(:,:,3) = Omap .* Bmap;
%maxVal = max(max(max(image)));
%image = image / maxVal;
scale = 1.0 / (10 ^ (maxVal * gamma));
image = min(1.0, max(0.0, power(image*scale, 1.0/2.2)));
end

%% Fast Bilateral Filter
% Implementation of "A Fast Approximation of the Bilateral Filter using a Signal Processing Approach"
% Modified from Jiawen(Kevin) Chen
function output = bilateral(input, sigmaS, sigmaR)
% parameters
height = size(input, 1);
width = size(input, 2);
minVal = min(min(input));
maxVal = max(max(input));
deltaVal = maxVal - minVal;

% data array
dsWidth = floor((width - 1) / sigmaS) + 7;
dsHeight = floor((height - 1) / sigmaS) + 7;
dsDepth = floor(deltaVal / sigmaR) + 7;
dsData = zeros(dsHeight, dsWidth, dsDepth);
dsWeights = zeros( dsHeight, dsWidth, dsDepth );

% downsampling
[idxJ, idxI] = meshgrid(0 : width - 1, 0 : height - 1);
di = round(idxI / sigmaS) + 4;
dj = round(idxJ / sigmaS ) + 4;
dz = round((input - minVal) / sigmaR) + 4;
for k = 1 : numel(dz),
    val = input(k);
    dik = di(k);
    djk = dj(k);
    dzk = dz(k);
    dsData(dik, djk, dzk) = dsData(dik, djk, dzk) + val;
    dsWeights(dik, djk, dzk) = dsWeights(dik, djk, dzk) + 1;
end

% filtering
[gX, gY, gZ] = meshgrid(0 : 2, 0 : 2, 0 : 2);
gX = gX - 1;
gY = gY - 1;
gZ = gZ - 1;
gSq = gX .^ 2 + gY .^ 2 + gZ .^ 2;
kernel = exp( -0.5 * gSq );
fDsData = convn(dsData, kernel, 'same');
fDsWeights = convn(dsWeights, kernel, 'same');

% normalizing
fDsWeights(fDsWeights == 0) = -100;
nDsData = fDsData ./ fDsWeights;
nDsData(fDsWeights < -1) = 0;

% upsampling
di = (idxI / sigmaS) + 4;
dj = (idxJ / sigmaS) + 4;
dz = (input - minVal) / sigmaR + 4;
output = interpn(nDsData, di, dj, dz);
end