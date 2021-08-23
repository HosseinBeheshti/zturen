close all;
clc;
clear;
simulation_time = 1e-4;
%% load log data
load_data_en = 1;
if load_data_en == 1
    fid=fopen('../../../log_data/BladeRF_Bands-L1.int16');
    x=fread(fid,2e5,'int16');
    fclose(fid);
end
%% Core initialize parameters
fs = 120e6;
ts = 1/fs;
input_signal_width = 4;
input_signal_binary_point = 3;
quantized_input = double(fi(x.*2^(input_signal_binary_point-15),1,input_signal_width,input_signal_binary_point))';
input_signal = [0:ts*12:ts*12*(length(x)-1); quantized_input]';
DDS_phase_width = 16;
DDS_signal_width = 16;
fc = randi([1 50],1,12)./10;
DDS_ch_pinc = fc.*(2^(DDS_phase_width)/fs);
multiplier_width = input_signal_width + DDS_signal_width;
multiplier__point = multiplier_width - 1;
%% integration and dump
integration_acc_width = 16;
integration_acc_point = 15;
%% code loop discriminator
% DLL Discriminators
DLL_Discriminators_mult_width = 32;
DLL_Discriminators_mult_point = 16;
coherent_discriminator_width = 32;
coherent_discriminator_point = 16;
EML_power_add_width = 32;
EML_power_add_point = 16;
EML_power_sub_width = 32;
EML_power_sub_point = 16;
normalized_EML_power_add_width = 32;
normalized_EML_power_add_point = 16;
normalized_EML_power_addsub_width = 32;
normalized_EML_power_addsub_point = 16;
normalized_EML_power_cordic_nstage = 11;
normalized_EML_power_cordic_width = 32;
normalized_EML_power_cordic_point = 32;
%% carrier loop discriminator
costas_pll_arctan_nstage = 8;
costas_pll_arctan_width = 32;
costas_pll_arctan_point = 16;
costas_pll_sign_width = 32;
costas_pll_sign_point = 16;
costas_pll_QI_width = 32;
costas_pll_QI_point = 16;







