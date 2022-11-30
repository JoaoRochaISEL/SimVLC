function [received,decoded4plot] = tfm_parity_decoder (paridade_OOK_MUX,mux_corrigido)

    decoded4plot = zeros(1,length(mux_corrigido));    

    received.R = zeros(1,length(mux_corrigido));
    received.G = zeros(1,length(mux_corrigido));
    received.B = zeros(1,length(mux_corrigido));
    received.V = zeros(1,length(mux_corrigido));
    
    for i = 1:length(paridade_OOK_MUX)
        paridade = paridade_OOK_MUX(i);
        switch paridade
            case 0
                %0 ou 14
                temp = mux_corrigido(i);
                diferenca1 = abs(0-temp);
                diferenca2 = abs(14-temp);
                if diferenca1 < diferenca2
                    %0
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 0;
                    decoded4plot(i) = 0;
                else
                    if diferenca2 < diferenca1
                        %14
                        received.R(i) = 1;
                        received.G(i) = 1;
                        received.B(i) = 1;
                        received.V(i) = 0;
                        decoded4plot(i) = 14;
                    else
                        %diferenca1 = diferenca2 (0 ou 14)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
                
            case 2
                % 7 ou 9
                temp = mux_corrigido(i);
                diferenca1 = abs(7-temp);
                diferenca2 = abs(9-temp);
                if diferenca1 < diferenca2
                    %7
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 1;
                    decoded4plot(i) = 7;
                else
                    if diferenca2 < diferenca1
                        %9
                        received.R(i) = 1;
                        received.G(i) = 0;
                        received.B(i) = 0;
                        received.V(i) = 1;
                        decoded4plot(i) = 9;
                    else
                        %diferenca1 = diferenca2 (7 ou 9)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
            case 4
                % 3 ou 13
                temp = mux_corrigido(i);
                diferenca1 = abs(3-temp);
                diferenca2 = abs(13-temp);
                if diferenca1 < diferenca2
                    %3
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 1;
                    decoded4plot(i) = 3;
                else
                    if diferenca2 < diferenca1
                        %13
                        received.R(i) = 1;
                        received.G(i) = 1;
                        received.B(i) = 0;
                        received.V(i) = 1;
                        decoded4plot(i) = 13;
                    else
                        %diferenca1 = diferenca2 (3 ou 13)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
            case 6
                %4 ou 10
                temp = mux_corrigido(i);
                diferenca1 = abs(4-temp);
                diferenca2 = abs(10-temp);
                if diferenca1 < diferenca2
                    %4
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 0;
                    decoded4plot(i) = 4;
                else
                    if diferenca2 < diferenca1
                        %10
                        received.R(i) = 1;
                        received.G(i) = 0;
                        received.B(i) = 1;
                        received.V(i) = 0;
                        decoded4plot(i) = 10;
                    else
                        %diferenca1 = diferenca2 (4 ou 10)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
            case 8
                %5 ou 11
                temp = mux_corrigido(i);
                diferenca1 = abs(5-temp);
                diferenca2 = abs(11-temp);
                if diferenca1 < diferenca2
                    %5
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 1;
                    decoded4plot(i) = 5;
                else
                    if diferenca2 < diferenca1
                        %11
                        received.R(i) = 1;
                        received.G(i) = 0;
                        received.B(i) = 1;
                        received.V(i) = 1;
                        decoded4plot(i) = 11;
                    else
                        %diferenca1 = diferenca2 (5 ou 11)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
            case 10%9 antes
                %2 ou 12
                temp = mux_corrigido(i);
                diferenca1 = abs(2-temp);
                diferenca2 = abs(12-temp);
                if diferenca1 < diferenca2
                    %2
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 0;
                    decoded4plot(i) = 2;
                else
                    if diferenca2 < diferenca1
                        %12
                        received.R(i) = 1;
                        received.G(i) = 1;
                        received.B(i) = 0;
                        received.V(i) = 0;
                        decoded4plot(i) = 12;
                    else
                        %diferenca1 = diferenca2 (2 ou 12)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
            case 12%11 antes
                %6 ou 8
                temp = mux_corrigido(i);
                diferenca1 = abs(6-temp);
                diferenca2 = abs(8-temp);
                if diferenca1 < diferenca2
                    %6
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 0;
                    decoded4plot(i) = 6;
                else
                    if diferenca2 < diferenca1
                        %8
                        received.R(i) = 1;
                        received.G(i) = 0;
                        received.B(i) = 0;
                        received.V(i) = 0;
                        decoded4plot(i) = 8;
                    else
                        %diferenca1 = diferenca2 (6 ou 8)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
            case 14%13 antes
                %1 ou 15
                temp = mux_corrigido(i);
                diferenca1 = abs(1-temp);
                diferenca2 = abs(15-temp);
                if diferenca1 < diferenca2
                    %1
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 1;
                    decoded4plot(i) = 1;
                else
                    if diferenca2 < diferenca1
                        %15
                        received.R(i) = 1;
                        received.G(i) = 1;
                        received.B(i) = 1;
                        received.V(i) = 1;
                        decoded4plot(i) = 15;
                    else
                        %diferenca1 = diferenca2 (1 ou 15)
                        desempate = fliplr(de2bi(mux_corrigido(i),4));
                        received.R(i) = desempate(1);
                        received.G(i) = desempate(2);
                        received.B(i) = desempate(3);
                        received.V(i) = desempate(4);
                        decoded4plot(i) = mux_corrigido(i);
                    end
                end
%                 case 15
%                 %1 ou 15
%                 temp = mux_corrigido(i);
%                 diferenca1 = abs(1-temp);
%                 diferenca2 = abs(15-temp);
%                 if diferenca1 < diferenca2
%                     %1
%                     received.R(i) = 0;
%                     received.G(i) = 0;
%                     received.B(i) = 0;
%                     received.V(i) = 1;
%                     decoded4plot(i) = 1;
%                 else
%                     if diferenca2 < diferenca1
%                         %15
%                         received.R(i) = 1;
%                         received.G(i) = 1;
%                         received.B(i) = 1;
%                         received.V(i) = 1;
%                         decoded4plot(i) = 15;
%                     else
%                         %diferenca1 = diferenca2 (1 ou 15)
%                         desempate = fliplr(de2bi(mux_corrigido(i),4));
%                         received.R(i) = desempate(1);
%                         received.G(i) = desempate(2);
%                         received.B(i) = desempate(3);
%                         received.V(i) = desempate(4);
%                         decoded4plot(i) = mux_corrigido(i);
%                     end
%                 end
            otherwise
                %decoded4plot(i) = 20; %Não encontrou nenhum dos niveis de paridade
                decoded4plot(i)=mux_corrigido(i);
                desempate = fliplr(de2bi(mux_corrigido(i),4));
                received.R(i) = desempate(1);
                received.G(i) = desempate(2);
                received.B(i) = desempate(3);
                received.V(i) = desempate(4);
        end  
    end
end
