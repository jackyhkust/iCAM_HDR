%% Ke Ma, Christopher Bodden
% CS 766 - Project 1 (HDR)

%% Recovers all response curves and constructs the radiance map
function [radmap, rG, gG, bG, rPxVals, gPxVals, bPxVals, rLgExps, gLgExps, bLgExps] = makeRadmap(imgs,expTimes,smoothness)
%% Load exposure time
B = log(expTimes);
%% Load images
rImgs(:,:,:) = imgs(:,:,1,:);
gImgs(:,:,:) = imgs(:,:,2,:);
bImgs(:,:,:) = imgs(:,:,3,:);
%% Sample pixels
rZ = samplePxs(rImgs);
gZ = samplePxs(gImgs);
bZ = samplePxs(bImgs);
%% Construct weighting function
w = zeros(256,1);
for i=1:128
    w(i) = i;
end
for i=129:256
    w(i) = 257 - i;
end
%% Solve for g and lE
[rG, rlE] = gSolve(rZ,B,smoothness,w);
[gG, glE] = gSolve(gZ,B,smoothness,w);
[bG, blE] = gSolve(bZ,B,smoothness,w);

% create points to plot

%red
rPxVals = zeros(1,numel(rZ));
rLgExps = zeros(1,numel(rZ));
k = 1;
for i=1:size(rZ,1)
    for j=1:size(rZ,2)
        rPxVals(k) = rZ(i,j);
        rLgExps(k) = B(j) + rlE(i);
        k = k+1;
    end
end

%green
gPxVals = zeros(1,numel(gZ));
gLgExps = zeros(1,numel(gZ));
k = 1;
for i=1:size(gZ,1)
    for j=1:size(gZ,2)
        gPxVals(k) = gZ(i,j);
        gLgExps(k) = B(j) + glE(i);
        k = k+1;
    end
end

%blue
bPxVals = zeros(1,numel(bZ));
bLgExps = zeros(1,numel(bZ));
k = 1;
for i=1:size(bZ,1)
    for j=1:size(bZ,2)
        bPxVals(k) = bZ(i,j);
        bLgExps(k) = B(j) + blE(i);
        k = k+1;
    end
end

%% Construct radiance map
rE = mergeExps(rImgs,B,rG,w);
gE = mergeExps(gImgs,B,gG,w);
bE = mergeExps(bImgs,B,bG,w);
radmap = cat(3,rE,gE,bE);
end