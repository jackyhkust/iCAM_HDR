function img = load_hdr(filename,width,height)

% Written by: Lawrence Taplin and Garrett M. Johnson
%
% Essentially this function reads in a binary HDR image, based
% on the transform of RGBE images using the pvalue -df -H -h
% command from Greg Ward's Radiance package

fid = fopen(filename,'r','b');
img = fread(fid,inf,'float');
fclose(fid);
img = permute(reshape(img,3,width,height),[3,2,1]);
