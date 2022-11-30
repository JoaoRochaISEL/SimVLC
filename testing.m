clc; close all; clear all;

x = [1 1 0 1 0];

N=20;
sem_ruido=x;

idx = 1;
for i = 1:length(sem_ruido)
    bit = sem_ruido(i);
    for ii = 1:N
        temp(idx) = bit;
        idx = idx+1;
    end
end

%SHOT
ruido_sinal = temp + poissrnd(0.5,1,length(sem_ruido)*N); titulo = 'Shot Noise';

%WHITE GAUSSIAN NOISE
%ruido_sinal = temp + wgn(1,length(sem_ruido)*N,-30); titulo = 'White Gaussian Noise';

%NORMAL
%ruido_sinal = temp+normrnd(0,0.1,[1,length(sem_ruido)*N]); titulo = 'Normal Noise';

%BINOMIAL
%ruido_sinal = temp+binornd(temp,0.5,1,length(sem_ruido)*N); titulo = 'Binomial Noise';

figure('Name','Ruido Testing')
stairs(temp,'LineWidth',2); axis tight; hold on;
plot(ruido_sinal); axis tight; hold on;
title(titulo)
