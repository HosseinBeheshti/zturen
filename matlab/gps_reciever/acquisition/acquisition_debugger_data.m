function [final_output,dds_output,ddc_out,fft_out,cm_out,ifft_out,g] = acquisition_debugger_data(fs,fc,fd,x,sat_num,fixed_point_bits)

%% timing info
ts=1/fs;
Ns=fs*1e-3;
%% CA code
g0 = cacode(sat_num,Ns/1023);
code_g = g0*2-1;
fftlength = 4096;
U_j = 2*pi*ts*(0:fftlength-1);
g = double(fi(conj(fft(code_g,fftlength)),1,fixed_point_bits.ca_fft_width,fixed_point_bits.ca_fft_point));
%%
theta = U_j*(fc+fd);
x0i = x(1:Ns);
dds_output = double(fi(cos(theta)+1j*sin(theta),1,fixed_point_bits.DDS_signal_width,fixed_point_bits.DDS_signal_point));
ddc_out = double(fi(x0i.*cos(theta)+1j*x0i.*sin(theta),1,fixed_point_bits.multiplier_width,fixed_point_bits.multiplier_point));
fft_out = double(fi(fft(ddc_out,fftlength),1,fixed_point_bits.fft_convert_width,fixed_point_bits.fft_convert_point));
o_i = real(fft_out);
o_q = imag(fft_out);
g_i = real(g);
g_q = imag(g);
cm_out = double(fi((o_i.*g_i-o_q.*g_q)+1j*(o_i.*g_q+o_q.*g_i),1,fixed_point_bits.cm_convert_width,fixed_point_bits.cm_convert_point));
ifft_out = double(fi(ifft(cm_out,fftlength),1,fixed_point_bits.ifft_convert_width,fixed_point_bits.ifft_convert_point));
final_output = double(fi(real(ifft_out).^2+imag(ifft_out).^2,1,fixed_point_bits.abs_multiplier_width,fixed_point_bits.abs_multiplier_point));
end