clc
clear
%%
F0=1023000;
Fs=4*F0;
simulation_dt=1/Fs;
IF_freq=1.25e6;
simulation_time=0.01;
visable_sat=[1  3  5];

sat_PN_shift=[-0 50.3 25]; %-1023 to 1023
sat_power=[0.6 0.6 0.6]; %0 to 1
sat_phase_shift=[0 0 0]/180*2*pi; %-360 to 360
sat_freq_shift=[-4900 1400 0]; %-5000 to 5000


bit_N=ceil(simulation_time/0.02);
bit_stream=floor(2*randi(2,1,bit_N)-3);


%%
t=(simulation_dt/2):simulation_dt:(bit_N*0.020);
analog_output=zeros(1,length(t));

for ii=1:length(visable_sat)
    sat_id=visable_sat(ii);
    sat_code=cacode(sat_id,Fs/F0)*2-1;
    sat_code=circshift(sat_code,round(sat_PN_shift(ii)*Fs/F0));
    sat_code_T=repmat(sat_code,1,bit_N*20);
    %%%%
    wave_form=sat_power(ii)*cos(2*pi*(IF_freq+sat_freq_shift(ii))*t+sat_phase_shift(ii));
    %%%%
    bit_stream_T=bit_stream(floor(t/0.02)+1);
    
    analog_output=analog_output+bit_stream_T.*sat_code_T.*wave_form;
end

analog_output=analog_output/rms(analog_output);
rms(analog_output)
analog_output_noise=awgn(analog_output,50)/2;
rms(analog_output_noise)
plot(analog_output_noise)
emulated_GPS_IF=fi(analog_output_noise,1,3,2);

% plot(emulated_GPS_IF);

save('emulated_GPS_IF.mat','emulated_GPS_IF')

%  plot(t,emulated_GPS_IF,'-+')
% 
%  plot(sat_code_T*1.1)



