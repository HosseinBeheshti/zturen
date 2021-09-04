close all;
clc;
clear;
%%
simulation_time = 40e-3;
scope_span = 1e-5;
%% load log data
if isfile('../../../log_data/BladeRF_Bands-L1.int16')
    fid=fopen('../../../log_data/BladeRF_Bands-L1.int16');
    x=fread(fid,2e5,'int16');
    fclose(fid);
else
    x = 2^16.*randn(1,1e6);
end
%% prepare input signal
sim_imp_clk_ratio = 5000/4096;
x1=[1 1j]*buffer(x,2);
x11 = real(x1(1:2:end)); % downsample to 5Mhz
x0 = x11(1:sim_imp_clk_ratio:end); % downsample to 4096 point for 1 ms
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
fft_input_scale = -2;
fft_output_scale = 2;%-log2(fft_length);
fft_convert_width = 20;
fft_convert_point = 8;
%% DDC param
DDS_phase_width = 24;
DDS_signal_width = 12;
DDS_signal_point = 11;
f_start = -2500*sim_imp_clk_ratio;
f_dds_change = 100;
f_start_phase = core_upsample_ratio*f_start/fs;
fd_phase_increment = core_upsample_ratio*(f_dds_change)/fs;
multiplier_width = 14;
multiplier_point = 11;
%% CA code
ca_fft_width = 14;
ca_fft_point = 3;
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
cm_width = 32;
cm_convert_width = 32;
cm_convert_point = 10;
ifft_input_scale = -21;
ifft_output_scale = 12;
ifft_convert_width = 22;
ifft_convert_point = 8;
abs_width = 32;
abs_point = 4;
%% syncronization latency
adc_addr_gen_latency = 3;
ddc_latency = 6;
ca_code_latency = 3;
correlator_latency = 19;
%% debugger data generator
fixed_point_bits.DDS_signal_width = DDS_signal_width;
fixed_point_bits.DDS_signal_point = DDS_signal_point;
fixed_point_bits.fft_convert_width = fft_convert_width;
fixed_point_bits.fft_convert_point = fft_convert_point;
fixed_point_bits.multiplier_width = multiplier_width;
fixed_point_bits.multiplier_point = multiplier_point;
fixed_point_bits.ca_fft_width = ca_fft_width;
fixed_point_bits.ca_fft_point = ca_fft_point;
fixed_point_bits.cm_convert_width = cm_convert_width;
fixed_point_bits.cm_convert_point = cm_convert_point;
fixed_point_bits.ifft_convert_width = ifft_convert_width;
fixed_point_bits.ifft_convert_point = ifft_convert_point;
fixed_point_bits.abs_width = abs_width;
fixed_point_bits.abs_point = abs_point;
% acquisition_debugger_data(fs,fc,fd,x,sat_num)
[sim_final_output,sim_dds_out,sim_ddc_out,sim_fft_out,sim_cm_out,sim_ifft_out,sim_g] = acquisition_debugger_data(4.096e6,0,-2500,adc_ram_init',30,0,fixed_point_bits);
[fix_final_output,fix_dds_out,fix_ddc_out,fix_fft_out,fix_cm_out,fix_ifft_out,fix_g] = acquisition_debugger_data(4.096e6,0,-2500,adc_ram_init',30,1,fixed_point_bits);

if exist('out','var') == 1
    a = abs(fix_ifft_out)'/2^10;
    b_temp = out.simout.signals.values;
    b_index = find(out.simout_index.signals.values~= 0);
    start_index = b_index(1);
    b = abs(b_temp(start_index:start_index+4095));
    c = diff(a-b);
    clc;
    close all;
    hold on;
    plot(a);
    plot(b);
    max_index = find(abs(c) == abs(max(c)));
    if (c(max_index) >= 0)
        max_error = max(abs(c(max_index)/a(max_index)));
    else
        max_error = max(abs(c(max_index)/b(max_index)));
    end
    X = sprintf('max_error is %f percent.',max_error*100);
    disp(X)
    hold off;
else
    a = abs(sim_final_output);
    b = abs(fix_final_output);
    c = diff(a-b);
    clc;
    close all;
    hold on;
    plot(a);
    plot(b);
    max_index = find(abs(c) == abs(max(c)));
    if (c(max_index) >= 0)
        max_error = max(abs(c(max_index)/a(max_index)));
    else
        max_error = max(abs(c(max_index)/b(max_index)));
    end
    X = sprintf('max_error is %f percent.',max_error*100);
    disp(X)
    hold off;
end



