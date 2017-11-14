function a = idl_dist(m,n);

% Written by: Lawrence Taplin
%
% Pretty much a direct port of the IDL
% Dist function...
%
% x=findgen(n)		;Make a row
% x = (x < (n-x)) ^ 2	;column squares
% if n_elements(m) le 0 then m = n
% 
% a = FLTARR(n,m,/NOZERO)	;Make array
% 
% for i=0L, m/2 do begin	;Row loop
% 	y = sqrt(x + i^2) ;Euclidian distance
% 	a[0,i] = y	;Insert the row
% 	if i ne 0 then a[0, m-i] = y ;Symmetrical
% 	endfor
% return,a

x=0:(n-1);		%Make a row
x = min(x,(n-x)).^2;	%column squares
if nargin ==1
    m = n;
end

a = zeros(m,n);	%Make array

for i=0:m/2	%Row loop
    y = sqrt(x + i.^2); %Euclidian distance
    a(i+1,:) = y;	%Insert the row
    if i ~= 0 
        a(m-i+1,:) = y; %Symmetrical
    end
end
