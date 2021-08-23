close all;
clc;
clear;
%%
simulation_time = 2e-3;
%% load log data
load_data_en = 1;
if load_data_en == 1
    fid=fopen('../../../log_data/BladeRF_Bands-L1.int16');
    x=fread(fid,2e5,'int16');
    fclose(fid);
end
%% data capture
fs_adc = 5e6;
ts_adc = 1/fs_adc;
%% Core initialize parameters
core_upsample_ratio = 24;
fs = core_upsample_ratio*fs_adc;
ts = 1/fs;
Ns=fs*1e-3; % data pt in 1 ms
input_signal_width = 3;
input_signal_binary_point = 2;
quantized_input = double(fi(x.*2^(input_signal_binary_point-1),1,input_signal_width,input_signal_binary_point))';
input_signal = [0:ts_adc:ts_adc*(length(x)-1); quantized_input]';
fft_length = 4096;
fft_scale = -log2(fft_length);
fft_convert_width = 8;
fft_convert_point = 7;
DDS_phase_width = 24;
DDS_signal_width = 8;
fc = 1.25e6;
f_dds_change = 500;
DDS_offset = (fc)/fs;
DDS_pinc =(f_dds_change)/fs;
adc_to_fft_latency = 18;
multiplier_width = 8;
multiplier_point = multiplier_width - 1;
%% CA code
ca_fft_width = 8;
ca_fft_point = 7;
ca_fft_coef = zeros(37,4096);
for i=1:37
    g0 = cacode(i,Ns/1e3/1.023);
    code_g = g0*2-1;
    g = conj(fft(code_g,fft_length));
    g_i = fi_bit(real(g),ca_fft_width);
    g_q = fi_bit(imag(g),ca_fft_width);
    ca_fft_coef(i,:) = (g_i)+(2^ca_fft_width*g_q);
end
%% correlatoin and peak detector
cm_width = 16;
cm_scale = 0;
cm_convert_width = 8;
cm_convert_point = 7;
ifft_scale = 0;
ifft_convert_width = 10;
ifft_convert_point = 7;
abs_multiplier_width = 8;
abs_multiplier_point = 7;
abs_adder_width = 8;
abs_adder_point = 7;

