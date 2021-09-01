function [final_output,dds_output,ddc_out,fft_out,cm_out,ifft_out,g] = acquisition_debugger_data(fs,fc,fd,x,sat_num)

%% timing info
ts=1/fs;
Ns=fs*1e-3;
%% CA code
g0 = cacode(sat_num,Ns/1023);
code_g = g0*2-1;
fftlength = 4096;
U_j = 2*pi*ts*(0:fftlength-1);
g = conj(fft(code_g,fftlength));
%%
theta = U_j*(fc+fd);
x0i = x(1:Ns);
dds_output = cos(theta)+1j*sin(theta);
ddc_out = x0i.*cos(theta)+1j*x0i.*sin(theta);
fft_out = fft(ddc_out,fftlength);
o_i = real(fft_out);
o_q = imag(fft_out);
g_i = real(g);
g_q = imag(g);
cm_out = (o_i.*g_i-o_q.*g_q)+1j*(o_i.*g_q+o_q.*g_i);
ifft_out = ifft(cm_out,fftlength);
final_output = real(ifft_out).^2+imag(ifft_out).^2;
end