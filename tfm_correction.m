function [corrigido] = tfm_correction(curvas,correction_plot)
    
    %tfm_correction - Tira o efeito capacitivo do sinal, pertencente à tese TFM49
    %corrigido = tfm_correction(curvas,correction_plot)
    %
    % Inputs (por ordem):
    % - curvas = Sinal com o efeito capacitivo (curvas)
    % - correction_plot = Se queremos fazer o plot ou não (1 = Sim, 0 = Não)
    %
    % Output:
    % - corrigido = Sinal (rectangular) sem o comportamento capacitivo
    
    %"Corrigir" o efeito capacitivo
    corrigido = zeros(1,length(curvas));
    derivada = curvas(1,2:end)-curvas(1,1:end-1);
    limite_up = max(derivada(1,:))*0.7;
    limite_down = min(derivada(1,:))*0.7;
    transitions_up = (derivada >= limite_up)*4;
    transitions_down = (derivada <= limite_down)*3;
    transitions = transitions_up + transitions_down;
    %
    %up_down_flag = 0;
    up_down_flag = round(curvas(1));%<-----
    up_value = round(max(curvas));
    down_value = round(min(curvas));
    %corrigido(1) = round(curvas(1));
    for iii = 1:length(transitions)
        z = transitions(iii);
        %corrigido(1) = round(curvas(1));
        if z ~= 4 && z ~= 3
            %corrigido(iii) = up_down_flag;
        else
            if z == 4 %Vai descer
                %curvas(iii:(iii+N-1)) = curvas(iii:(iii+N-1))-curva3;
                up_down_flag = up_value;
            else % Vai subir (x == 3)
                %curvas(iii:(iii+N-1)) = curvas(iii:(iii+N-1))+curva3;
                up_down_flag = down_value;
            end
            
        end
%         if iii==1
%             corrigido(1) = round(curvas(1));
%         end
        corrigido(iii+1) = up_down_flag;
    end
    %
    if correction_plot
        figure('name','Corrigir Efeito Capacitivo')
        plot(curvas); axis tight; hold on;
        %plot(corrigido); axis tight; hold on;
        %plot(derivada); axis tight; hold on;
        %plot(transitions); axis tight; hold on;
        plot(corrigido); axis tight; hold on;
        %legend('Antes de ser Corrigido','derivada','transitions','Corrigido','Location','Best')
        legend('Antes de ser Corrigido','Corrigido','Location','Best'); ylim([min(corrigido)-0.5 max(corrigido)+0.5])
    end
    
end
