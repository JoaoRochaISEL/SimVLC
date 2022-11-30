function [sinal_mod_out] = tfm_modulation(sinal_mod_in,mod_select,flag_plot)
    %tfm_modulation - Modula o sinal, pertencente à tese TFM49
    %sinal_mod_out = tfm_modulation(sinal_mod_in, mod_select)
    %
    % Inputs (por ordem):
    % - sinal_mod_in = Sinal original (não modulado)
    % - mod_select = Tipo de modulação selecionada pela GUI
    % - flag_plot = Se queremos fazer o plot ou não (1 ou 0)
    %
    % Output:
    % - sinal_mod_out = Sinal modulado
    
    %PARÂMETROS:
    sinal_mod_in = sinal_mod_in';

    if strcmp(mod_select,'OOK') == 1
        sinal_mod_out = sinal_mod_in; %Não fazemos nada porque o Rodrigues já fez isto em OOK-RZ
    else
        if strcmp(mod_select,'OOK-NRZ') == 1
            sinal_mod_out = zeros(1,2*length(sinal_mod_in));
            for i = 1:length(sinal_mod_in)
                %temp2 = sinal_mod_in(1,:);
                temp2 = sinal_mod_in;
                switch temp2(i)
                    case 0
                        sinal_mod_out((i*2)-1) = 1;
                        sinal_mod_out((i*2)) = -1;
                    case 1
                        sinal_mod_out((i*2)-1) = -1;
                        sinal_mod_out((i*2)) = 1;
                end
            end
        else
            if strcmp(mod_select,'Manchester') == 1
                sinal_mod_out = zeros(1,2*length(sinal_mod_in));
                for i = 1:length(sinal_mod_in)
                    %temp2 = sinal_mod_in(1,:);
                    temp2 = sinal_mod_in;
                    %switch temp2
                    switch temp2(i)
                        case 0
                            sinal_mod_out((i*2)-1) = 0;
                            sinal_mod_out((i*2)) = 1;
                        case 1
                            sinal_mod_out((i*2)-1) = 1;
                            sinal_mod_out((i*2)) = 0;
                    end
                end
            else
                if strcmp(mod_select,'2-PPM') == 1
                    sinal_mod_out = zeros(1,2*length(sinal_mod_in));
                    for i = 1:length(sinal_mod_in)
                        %temp2 = sinal_mod_in(1,:);
                        temp2 = sinal_mod_in;
                        %switch temp2
                        switch temp2(i)
                            case 0
                                sinal_mod_out((i*2)-1) = 1;
                                sinal_mod_out((i*2)) = 0;
                            case 1
                                sinal_mod_out((i*2)-1) = 0;
                                sinal_mod_out((i*2)) = 1;
                        end
                    end
                else
                    if strcmp(mod_select,'4-PPM') == 1
                        sinal_mod_out = zeros(1,2*length(sinal_mod_in));
                        for i = 1:2:length(sinal_mod_in)
                            temp2 = sinal_mod_in(1,:);
                            dois_bits = [temp2(i) temp2(i+1)];
                            if sum(dois_bits == [0 0]) == 2
                                sinal_mod_out(((i+1)*2)-3:(i+1)*2) = [1 0 0 0];
                            elseif sum(dois_bits == [0 1]) == 2
                                sinal_mod_out(((i+1)*2)-3:(i+1)*2) = [0 1 0 0];
                            elseif sum(dois_bits == [1 0]) == 2
                                sinal_mod_out(((i+1)*2)-3:(i+1)*2) = [0 0 1 0];
                            elseif sum(dois_bits == [1 1]) == 2
                                sinal_mod_out(((i+1)*2)-3:(i+1)*2) = [0 0 0 1];
                            end
                        end
                    else
                        error(['ERROR: Modulation scheme ',mod_select,' has not been implemented!']);
                    end
                end
            end
        end
    end
    
    %REPRESENTAÇÃO GRÁFICA (SE QUISERMOS)
    if (flag_plot == 1) && strcmp(mod_select,'OOK-RZ')==0
        figure('name','Modulation Plot')
        
        subplot(2,1,1)
        stairs(sinal_mod_in(1,:),'LineWidth',1.5); axis tight;
        title('Data Bits')
        xticks([1:10])
        yticks([0 1])
        xlim([1 10]); ylim([-0.5 1.5])
        set(gca,'XGrid','on')
        
        subplot(2,1,2)
        stairs(sinal_mod_out(1,:),'LineWidth',1.5); axis tight;
        title(mod_select)
        if strcmp(mod_select,'Manchester') || strcmp(mod_select,'OOK-NRZ')==1 || strcmp(mod_select,'2-PPM')
            xticks([1:2:19])
            xlim([1 19]); %ylim([-1.5 1.5])
        elseif strcmp(mod_select,'4-PPM')==1
            xticks([1:4:19])
            xlim([1 19]); %ylim([-0.5 1.5])
        end
        ylim([min(sinal_mod_out(1,:))-0.5 max(sinal_mod_out(1,:))+0.5])
        yticks([-1 0 1])
        set(gca,'XGrid','on')
    end
    
end