function xsc = fi_bit(x,B)
L = floor(log2((2^(B-1)-1)/max(abs(x))));  % Round towards zero to avoid overflow
xsc = round(x*2^L)*2^-L;