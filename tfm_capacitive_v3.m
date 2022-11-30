function [depois,pulse_ver] = tfm_capacitive_v3(antes,capacitive_howmuch,capacitive_plot,N)
    %clc; close all; clear all;
    %antes = [1 0 1 1 0 0 1];
    %capacitive_howmuch = 3;
    %capacitive_plot = 1;
    %N = 16;

    %tfm_capacitive - Simula o comportamento capacitivo dos LEDs, pertencente à tese TFM49
    %depois = tfm_capacitive(antes,capacitive_howmuch,capacitive_plot)
    %pulse_ver = Sinal original para plot nos resultados
    %
    % Inputs (por ordem):
    % - sinal_mod_in = Sinal original (sem o comportameno capacitivo)
    % - capacitive_howmuch = Quanto depressa/lento é a curva
    % - capacitive_plot = Se queremos fazer o plot ou não (1 = Sim, 0 = Não)
    % - N = Número de amostras para representar cada bit
    %
    % Output:
    % - depois = Sinal com o comportamento capacitivo

    %PARÂMETROS:
    %N = 16;                 %Número de amostras para representar cada bit
    
    depois = zeros(1,length(antes)*N);
    idx = 1;
    for i = 1:length(antes)
        bit = antes(1,i);
        for ii = 1:N
            depois(idx) = bit;
            idx = idx+1;
        end
    end
    depois2 = depois;
    %"depois2" é o "antes" mas com N amostras por bit
    
    %Conta nº amostras por "permanência de bit"
    perm = [];
    count = 1;
    for i = 1:length(depois2)-1
        if depois2(i)==depois(i+1)
            count = count+1;
        else
            perm = [perm count];
            count = 1;
        end
        if i == length(depois2)-1
            perm = [perm count];
        end
    end
    
    depois = [0 depois]; %Obrigamos a começar a 0 porque o emissor acaba por transitar para 1, mesmo que o 1º bit seja 1
    derivada = depois(1,2:end)-depois(1,1:end-1);
    depois = depois(2:end); %Tiramos o 0 anterior porque só interessa para a derivada
    limite_up = max(derivada(1,:))*0.7;
    limite_down = min(derivada(1,:))*0.7;
    transitions_up = (derivada >= limite_up)*4;
    transitions_down = (derivada <= limite_down)*3;
    transitions = transitions_up + transitions_down;
    
    %Comportamento capacitivo:
    curva3 = exp(-[1:N]/((N)/capacitive_howmuch));
    curva3_long = exp(-[1:N*length(antes)]/((N)/capacitive_howmuch));
    curva5 = [];
    for i = 1:length(perm)
        NN = perm(i);
        curva4 = exp(-[1:NN]/((NN)/capacitive_howmuch));
        curva5 = [curva5 curva4];
    end
    %curva3(1) = 0; %<----- WORKAROUND
    temp = 0;
    for iii = 1:length(transitions)
        z = transitions(iii);
        if z ~= 4 && z ~= 3
        else
            if z == 4 %Vai descer
                %depois(iii:(iii+N-1)) = depois(iii:(iii+N-1))-curva3;
                temp = temp+1;
                depois(iii:(iii+perm(temp)-1)) = depois(iii:(iii+perm(temp)-1))-curva3_long(1:perm(temp));
            else % Vai subir (x == 3)
                %depois(iii:(iii+N-1)) = depois(iii:(iii+N-1))+curva3;
                temp = temp+1;
                if perm(temp) == 16
                    %perm(temp) = 15;
                end
                depois(iii:(iii+perm(temp)-1)) = depois(iii:(iii+perm(temp)-1))+curva3_long(1:perm(temp));
            end
        end
    end
      
    if capacitive_plot
        
        figure('name','Efeito Capacitivo')
        plot(depois2,'LineWidth',1); axis tight; hold on;
        plot(depois,'LineWidth',1); axis tight; hold on;
        legend('Sem curvas','Com curvas')
        ylim([min(depois)-0.5 max(depois)+0.5])
        title(['N/',num2str(capacitive_howmuch)])
        
    end
    
    %"Corrigir" o efeito capacitivo
    %corrigido = tfm_correction(depois,capacitive_plot);
    
    %depois = antes;
    pulse_ver = depois2;

end
