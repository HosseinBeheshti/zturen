close all;
clc;
clear;
%%
simulation_time = 2e-3;
scope_span = 1e-5;
%% load log data
fid = fopen('../../../log_data/BladeRF_Bands-L1.int16');
x = fread(fid,2e5,'int16');
fclose(fid);
%% prepare input signal
sim_imp_clk_ratio = 5000/4096;
x1=[1 1j]*buffer(x,2);
x11 = real(x1(1:2:end));% downsample to 5Mhz
x0 = x11(1:sim_imp_clk_ratio:end);% downsample to 4096 point for 1 ms
x_in = round(x0*2^-8); % 3 bit data
%% data capture
fs_adc = 5e6;
ts_adc = 1/fs_adc;
%% Core initialize parameters
core_upsample_ratio = 24;
fs = core_upsample_ratio*fs_adc;
ts = 1/fs;
Ns=fs*1e-3; % data pt in 1 ms
input_signal_width = 3;
input_signal_binary_point = 0;
quantized_input = double(fi(x_in.*2^(input_signal_binary_point-1),1,input_signal_width,input_signal_binary_point))';
adc_ram_init = quantized_input(1:4096);
input_signal = [0:ts_adc:ts_adc*(length(quantized_input)-1); quantized_input']';
%% FFT param
fft_length = 4096;
fft_scale = -log2(fft_length);
fft_convert_width = 21;
fft_convert_point = 19;
%% DDC param
DDS_phase_width = 24;
DDS_signal_width = 12;
f_start = -2500*sim_imp_clk_ratio;
f_dds_change = 100;
f_start_phase = core_upsample_ratio*f_start/fs;
fd_phase_increment = core_upsample_ratio*(f_dds_change)/fs;
multiplier_width = 8;
multiplier_point = multiplier_width - 1;
%% CA code
ca_fft_width = 10;
ca_fft_point = 0;
ca_fft_coef = zeros(37,4096);
for i=1:37
    g0 = cacode(i,(4.096e6*1e-3)/1023);
    code_g = g0*2-1;
    g = conj(fft(code_g,fft_length));
    g_i = fi(real(g),1,ca_fft_width,ca_fft_point);
    g_q = fi(imag(g),1,ca_fft_width,ca_fft_point);
    ca_fft_coef(i,:) = bitconcat(g_i,g_q);
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
%% syncronization latency
adc_addr_gen_latency = 3;
ddc_latency = 5;
ca_code_latency = 3;
correlator_latency = 19;
%% debugger data generator
% acquisition_debugger_data(fs,fc,fd,x,sat_num)
[sim_final_output,sim_dds_output,sim_ddc_out,sim_fft_out,sim_cm_out,sim_ifft_out,sim_g] = acquisition_debugger_data(4.096e6,0,-2500,adc_ram_init',30);
if exist('out','var') == 1
    a = real(sim_cm_out)';
    start_index = 12470;
    b_temp = out.simout.signals.values;
    b = b_temp(start_index:start_index+4095);
    c = diff(a-b);
    clc;
    close all;
    hold on;
    plot(a);
    plot(b);
    max_index = find(abs(c) == abs(max(c)));
    if (c(max_index) >= 0)
        max_error = max(abs(c(max_index)/a(max_index)));
        disp("A");
    else
        max_error = max(abs(c(max_index)/b(max_index)));
        disp("B");
    end
    X = sprintf('max_error is %f percent.',max_error*100);
    disp(X)
    hold off;
end



