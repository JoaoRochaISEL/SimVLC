function [ruido_bits,ruido_sinal] = tfm_ruido(sem_ruido,ruido_select,flag_plot)
    %tfm_ruido - Adiciona ruído, pertencente à tese TFM49
    %[ruido_bits,ruido_sinal] = tfm_ruido(sem_ruido, ruido_select)
    %
    % Inputs (por ordem):
    % - sem_ruido = Sinal original sem ruído
    % - ruído_select = Tipo de ruído selecionado pela GUI
    % - flag_plot = Se queremos fazer o plot ou não (1 ou 0)
    %
    % Output:
    % - ruido_bits = Bits correspondente ao sinal após adicionado ruído
    % - ruido_sinal = Sinal de ruído (oscilações no plot)
    
    %PARÂMETROS:
    ruido_lambda = 0.5;
    ruido_power = -30;         %[dBW] %-130??
    ruido_mean = ruido_lambda;
    ruido_desvio_padrao = 1;
    binomial_n = 1;             %Number of trials
    binomial_p = 0.5;           %Success probability
    N = 10;                     %Número de amostras para representar cada bit
    
    temp = zeros(1,length(sem_ruido)*N);
    if strcmp(ruido_select,'None') == 1
        ruido_sinal = sem_ruido;  %Não adicionamos ruído
        ruido_bits = sem_ruido;   %Os bits não são afectados
    else
        idx = 1;
        for i = 1:length(sem_ruido)
            bit = sem_ruido(1,i);
            for ii = 1:N
                temp(idx) = bit;
                idx = idx+1;
            end
        end
        if strcmp(ruido_select,'Shot') == 1
            %ruido_sinal = sem_ruido+poissrnd(ruido_lambda,1,length(sem_ruido));
            %ruido_sinal = temp+poissrnd(ruido_lambda,1,length(sem_ruido)*N);
            ruido = poissrnd(0.5,1,length(sem_ruido)*N);
            ruido(2:2:end) = ruido(2:2:end)*-1;
            ruido_sinal = temp + ruido;
            
        else
            if strcmp(ruido_select,'White Gaussian') == 1
                 ruido_sinal = temp + wgn(1,length(sem_ruido)*N,-30); %-30 dBW
            else
                if strcmp(ruido_select,'Normal') == 1
                    %ruido_sinal = sem_ruido+normrnd(ruido_mean,ruido_desvio_padrao,[1,length(sem_ruido)]);
                    %ruido_sinal = temp+normrnd(ruido_mean,ruido_desvio_padrao,[1,length(sem_ruido)*N]);
                    ruido_sinal = temp+normrnd(0,0.1,[1,length(sem_ruido)*N]);
                else
                    if strcmp(ruido_select,'Binomial') == 1
                        %ruido_sinal = sem_ruido+binornd(binomial_n,binomial_p,1,length(sem_ruido));
                        %ruido_sinal = temp+binornd(binomial_n,binomial_p,1,length(sem_ruido)*N);
                        ruido = binornd(temp,0.5,1,length(sem_ruido)*N);
                        ruido(2:2:end) = ruido(2:2:end)*-1;
                        ruido_sinal = temp+ruido;
                        %ESTE
                    else
                        error('ERROR: Noise type not yet implemented!');
                    end
                end
            end
        end
    end
    
    %A PARTIR DO SINAL COM RUIDO, CONVERTER DE VOLTA EM BITS (ALGUNS AGORA ERRADOS)
    if strcmp(ruido_select,'None')==0
        ruido_bits = zeros(1,length(sem_ruido));
        idx=1;
        for i = 1:N:length(ruido_sinal)
            grupo_bits = ruido_sinal(i:i+(N-1));
            %ruido_bits(idx) = round(mean(grupo_bits));%SERÁ QUE O ROUND É BOA IDEIA???
            ruido_bits(idx) = mean(grupo_bits);
            idx=idx+1;
        end
    end

    %REPRESENTAÇÃO GRÁFICA (SE QUISERMOS)
    if (flag_plot == 1) && strcmp(ruido_select,'None')==0
        figure('name','Noise Plot')
        stairs(temp,'LineWidth',1.5); axis tight; hold on;
        plot(ruido_sinal); axis tight; hold off;
        legend('Without Noise','With Noise','Location','NorthEast')
        title([ruido_select,' Noise'])
        yticks([-1 0 1])
        xlim([1 19*N])
        xticks([1:N*2:19*N])
        ylim([-1.3 1.5])
        set(gca,'XTickLabel',{'1','3','5','7','9','11','13','15','17','19'})
        set(gca,'XGrid','on')
        
        figure('name','Média Ruído')
        stairs(sem_ruido(1,:),'LineWidth',1.5); axis tight; hold on;
        stairs(ruido_bits(1,:),'LineWidth',1.25); axis tight; hold off;
        legend('Original','Média Ruído','Location','Best')
        ylim([-1 2])
    end
    
end
