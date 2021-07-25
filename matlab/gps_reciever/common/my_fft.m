function [y_i,y_q]=my_fft(x_i,x_q)
    x=cast((x_i+1i*x_q),'like',1+2i);
    y=fft(x)/256; %%4096
    y_i=fi(real(y),1,8,7);
    y_q=fi(imag(y),1,8,7);
end
