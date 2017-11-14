function detail_s = iCAM06_LocalContrast(detail, base_img)
% steven's effect
% written by Jiangtao (Willy) Kuang
% Feb. 20, 2006

La = 0.2*base_img(:,:,2);
k = 1./(5*La+1);
FL = 0.2*k.^4.*(5*La)+0.1*(1-k.^4).^2.*(5*La).^(1/3);
% default parameter settings: a =0.25, b=0.8;
detail_s = detail.^(repmat((FL+0.8),[1,1,3]).^.25);
% to turn off the details enhancement, comment the line above and uncomment the line below 
% detail_s = detail;