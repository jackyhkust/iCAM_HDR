% function to write a radiance picture file and header
% input file is a double format 3-D matrix
% Jiangtao Kuang
% May, 2005

function write_radiance(img, filename)

tic

% open the file
fid = fopen(filename, 'wb');

% write header
lines{1} = '#?RGBE';
lines{2} = 'FORMAT=32-bit_rle_rgbe';
x = size(img,2); y = size(img,1);
lines{3} = '';
lines{4} = ['-Y ' num2str(y) ' +X ' num2str(x)];
fprintf(fid, '%s\n', lines{1});
fprintf(fid, '%s\n', lines{2});
fprintf(fid, '%s\n', lines{3});
fprintf(fid, '%s\n', lines{4});

str = computer;

% write data
% float to RGBE
rgbe = float2rgbe(img);
num_scanlines = y; scanline_width = x;
% RGBE to codes
for  scanline=1:num_scanlines
    data = 2;  % indicate this file is run length encoded
    fwrite(fid, data, 'uint8');
    data= 2; 
    fwrite(fid, data, 'uint8');
    if strcmp(str, 'PCWIN')
        % PC codes
        data = x;   % scanline width 
        fwrite(fid, bitshift(data,-8), 'uint8');
        fwrite(fid, bitand(data,255), 'uint8');
    else
        % Macintosh codes
        data = x;   % scanline width 
        fwrite(fid, data, 'uint16');
    end
    scanline_buffer = squeeze(rgbe(scanline, :, :));
    if scanline == 132
        a = 1;
    end
    for i=1:4
        encoding_data = scanline_buffer(:,i);
        d = [(find(encoding_data(1:end-1) ~= encoding_data(2:end)))' length(encoding_data)];
        n = diff([0 d]);
        ddata = encoding_data(d);
        if max(n)>127
            ind = find((n-127)>0);
            % 1:ind(1)
            n_pine(1:ind(1)-1) = n(1:ind(1)-1); ddata_pine(1:ind(1)-1) = ddata(1:ind(1)-1);
            ptr = ind(1);
            for j = 1:length(ind)
                % ind(j)
                split_num = fix(n(ind(j))/127);
                n_pine(ptr:ptr+split_num-1) = repmat(127,1,split_num);
                ddata_pine(ptr:ptr+split_num-1) = repmat(ddata(ind(j)),1,split_num);
                ptr = ptr+split_num;
                if (n(ind(j))-127*split_num>0)
                    n_pine(ptr) = n(ind(j))-127*split_num;
                    ddata_pine(ptr) = ddata(ind(j));
                    ptr = ptr+1;
                end
                % ind(j):ind(j+1)
                if j<length(ind)
                    d_n = ind(j+1)-ind(j);
                    if d_n>1
                        n_pine(ptr:ptr+d_n-2) = n(ind(j)+1:ind(j+1)-1);
                        ddata_pine(ptr:ptr+d_n-2) = ddata(ind(j)+1:ind(j+1)-1);
                        ptr = ptr+d_n-1;
                    end
                end
            end
            n_pine(ptr:ptr+length(n)-ind(j)-1) = n(ind(j)+1:end);
            ddata_pine(ptr:ptr+length(n)-ind(j)-1) = ddata(ind(j)+1:end);
            n = n_pine; ddata = ddata_pine;
            clear n_pine ddata_pine ptr
        end      
        code(1,:) = n+128;
        code(2,:) = ddata;
        code = code(:);
        fwrite(fid, code, 'uint8');
        clear code
    end
end

fclose(fid);

toc






% standard conversion from float pixels to rgbe pixels
% the last dimension is assumed to be color
function [rgbe] = float2rgbe(rgb) 
s = size(rgb);
rgb = reshape(rgb,prod(s)/3,3);
rgbe = reshape(repmat(uint8(0),[s(1:end-1),4]),prod(s)/3,4);
v = max(rgb,[],2); %find max rgb
l = find(v>1e-32); %find non zero pixel list
rgbe(l,4) = uint8(round(128.5+log(v(l))/log(2))); %find E
rgbe(l,1:3) = uint8(rgb(l,1:3)./repmat(2.^(double(rgbe(l,4))-128-8),1,3)); %find rgb multiplier
rgbe = reshape(rgbe,[s(1:end-1),4]); %reshape back to original dimensions

% standard conversion from rgbe to float pixels */
% note: Ward uses ldexp(col+0.5,exp-(128+8)).  However we wanted pixels */
%       in the range [0,1] to map back into the range [0,1].            */
function [rgb] = rgbe2float(rgbe)
s = size(rgbe);
rgbe = reshape(rgbe,prod(s)/4,4);
rgb = zeros(prod(s)/4,3);
l = find(rgbe(:,4)>0); %nonzero pixel list
rgb(l,:) = double(rgbe(l,1:3)).*repmat(2.^(double(rgbe(l,4))-128-8),1,3);
rgb = reshape(rgb,[s(1:end-1),3]);

