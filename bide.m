function dec = bide(k)

str = string(k);
bin_nr=[str];
%bin_nr = '110101';
dec = 0;
for i = 1 : length(bin_nr)
    dec = dec + str2num(bin_nr(i)) * 2^(length(bin_nr) - i);
end
dec


