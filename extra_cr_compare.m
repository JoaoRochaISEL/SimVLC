%function [depois,pulse_ver] = tfm_capacitive_v3(antes,capacitive_howmuch,capacitive_plot,N)
    clc; close all; clear all;
    
    chosen_Cr = 3.4;
    
    %antes = [0 1 1 0 0 1 1];
    %antes = [0 1 0 1 1 0 0];
    %antes = rand(1,7)<.5;
    %antes = [0 1 0 1];
    %antes = [0 1 0 0 1 1 0 1];
    antes = [0 1 1 0 0 1 0 1];
    %capacitive_howmuch = 3;
    capacitive_plot = 0;
    N = 16;
    
    lol = tfm_capacitive_v3(antes,13,capacitive_plot,N);
    lmao = tfm_capacitive_v3(antes,8,capacitive_plot,N);
    xd = tfm_capacitive_v3(antes,chosen_Cr,capacitive_plot,N);
    %xd(17) = [];
    xd(16:47) = (xd(48:79)*(-1))+1;
    square_wave = tfm_capacitive_v3(antes,200,capacitive_plot,N);
    square_wave(1) = [];
    
    figure('name','Cr Compare')
    stairs(square_wave,'k--','LineWidth',1); axis tight; hold on;
    plot(lol,'b','LineWidth',1.5); axis tight; hold on;
    plot(lmao,'r','LineWidth',1.5); axis tight; hold on;
    plot(xd,'Color','#00CE19','LineWidth',1.5); axis tight; hold on;
    legend('Square Wave','C_r = 13','C_r = 8',['C_r = ',num2str(chosen_Cr)],'Location','north','NumColumns',4)
    ylim([-0.1 1.25])
    xlabel('Time [ms]')
    ylabel('Amplitude')
    xticks([0:N:N*length(antes)])
    xticklabels([0.08:0.08:0.08*length(antes)])
    set(gca, 'YGrid', 'off', 'XGrid', 'on')

%end