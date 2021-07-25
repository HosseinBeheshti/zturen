% close all;
clear;
clc;
% Be esme Allah
%% defined parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
F_sample = 5e6;
N_sample = F_sample*1e-3;
F_samplenew = 4096e3;
N_samplenew = F_samplenew*1e-3;
FFT_size = 4096;
%% Data from ADC and decimation
load ../emulator/emulated_GPS_IF% 20 ms data with fs = 5MHz
% Decimation
index = round(1:N_sample/N_samplenew:N_sample);
IF_data = emulated_GPS_IF(index);


%% Domain of doppler search
IF_freq = 1.25e6;
Dplr_freq = 5000;
Fstp = 500;
N_sat = 37;

F_start = IF_freq-Dplr_freq;
F_stop = IF_freq+Dplr_freq;
freq_dplr = F_start:Fstp:F_stop;
N_freq = length(freq_dplr);


%% saved variable in FPGA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sin_fd = zeros(N_freq,FFT_size);  %%
cos_fd = zeros(N_freq,FFT_size);  %%
PN_F_I = zeros(N_sat,FFT_size); %%
PN_F_Q = zeros(N_sat,FFT_size); %%
    %% Generate doppler freq (only for matlab)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    time =(0:FFT_size-1)/F_samplenew;
    for fd=1:N_freq
        sin_fd(fd,:) = fi(sin(2*pi*freq_dplr(fd)*time),1,8,7);
        cos_fd(fd,:) = fi(cos(2*pi*freq_dplr(fd)*time),1,8,7);
    end
    %% Generate frequecny domain of PN (only for matlab)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    for sat_id = 1:N_sat
        PN_T(sat_id,1:N_samplenew) = cacode(sat_id,F_samplenew/1023000)*2-1;
        PN_T(sat_id,N_samplenew+1:FFT_size) = 0;
        PN_F = fft(PN_T(sat_id,:));
        FFT_max = 512;%max(abs(PN_F));
        PN_F_I(sat_id,:) = fi(real(PN_F)/FFT_max,1,8,7);
        PN_F_Q(sat_id,:) = fi(-1*imag(PN_F)/FFT_max,1,8,7); %-1 for conjucate
    end

%% Course acquisitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for sat_id = 1:5%N_sat
    sat_id
    for fd=1:N_freq
        zIF_T_I = fi(IF_data.*cos_fd(fd,:),1,8,7);
        zIF_T_Q = fi(IF_data.*sin_fd(fd,:),1,8,7);
        [zIF_F_I,zIF_F_Q] = my_fft(zIF_T_I,zIF_T_Q);
        prod_I = fi(zIF_F_Q.*PN_F_Q(sat_id,:)-zIF_F_I.*PN_F_I(sat_id,:),1,8,7);
        prod_Q = fi(zIF_F_Q.*PN_F_I(sat_id,:)+zIF_F_I.*PN_F_Q(sat_id,:),1,8,7);
        [corr_I,corr_Q] = my_ifft(prod_I,prod_Q);
        corr_abs = fi(sqrt(corr_I.^2+corr_Q.^2),1,8,7);
%         plot(corr_abs*1.1);
        [max_mag(fd),max_ind(fd)] = max(corr_abs);
    end
    [ Est_pn(sat_id),Est_dopp(sat_id),Snr_det(sat_id)] = my_max(max_ind,max_mag);
end
Est_pn
Est_dopp
Snr_det
%% fine acquisition
% number_1ms_data = number_1ms_data-1;
% z5=x1(k1:k1+number_1ms_data*Ns-1); % take 20 ms data starting with C/A code
% za5=z5.* repmat(code_g,1,number_1ms_data);% create cw from 20 sets of data
% zb5=za5 .* exp(1j*2*pi*Fdp1*ts*[0:number_1ms_data*Ns-1]); % one DFT component
% Angle_one = angle(sum(reshape(zb5,Ns,number_1ms_data)));
% [~,w2]=max(db(fft(exp(1j*unwrap(mod(Angle_one,pi)*2)/2) ,number_1ms_data*20)));
% FF1=1/number_1ms_data/20*-(mod((w2-1)+number_1ms_data*10,number_1ms_data*20)-number_1ms_data*10);
% fd0=Fdp1+FF1*1000;