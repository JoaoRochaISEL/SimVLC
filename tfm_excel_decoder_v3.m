function [] = tfm_excel_decoder_v2(imported_excel,DeltaT,BER_FLAG)
    
    raw_excel = readmatrix(imported_excel,'Sheet','OOK');
    [excel_rows,excel_columns] = size(raw_excel);
    
    %% SCENARIO MEASUREMENTS FILE
    if excel_columns == 7+3 || excel_columns == 7 %SCENARIO MEASUREMENTS FILE
        
        if ~isempty(strfind(imported_excel,'Scenario1'))
            disp('--->Scenario 1:');
            found_OOK.inicio = 951;
            found_MAN.inicio = 951;
            found_OOK.fim = 2012;
            found_MAN.fim = 3075;
            sent.R = [1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
            sent.G = [1 0 1 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 1 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
            sent.B = [1 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 1 0 0 0 0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
            sent.V = [1 0 1 0 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
        else
            if ~isempty(strfind(imported_excel,'Scenario2t0'))
                disp('--->Scenario 2 (t0):');
                found_OOK.inicio = 951;
                found_MAN.inicio = 951;
                found_OOK.fim = 2012;
                found_MAN.fim = 3075;
                sent.R = [1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
                sent.G = [1 0 1 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 1 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
                sent.B = [1 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 1 0 0 0 0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
                sent.V = [1 0 1 0 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
            else
                if ~isempty(strfind(imported_excel,'Scenario2t1'))
                    disp('--->Scenario 2 (t1):');
                    found_OOK.inicio = 951;
                    found_MAN.inicio = 951;
                    found_OOK.fim = 2012;
                    found_MAN.fim = 3075;
                    sent.R = [1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
                    sent.G = [1 0 1 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
                    sent.B = [1 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 1 0 0 0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
                    sent.V = [1 0 1 0 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
                else
                    if ~isempty(strfind(imported_excel,'Scenario3A'))
                        disp('--->Scenario 3 (User A):');
                        found_OOK.inicio = 951;
                        found_MAN.inicio = 951;
                        found_OOK.fim = 2012;
                        found_MAN.fim = 3075;
                        sent.R = [1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 0 1 0 0 0 0 0 1 0 1 0 0 0 1 1 0 0 0 1 1 0 0 0];
                        sent.G = [1 0 1 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0 0 0 0 1 0 0 0 1 1 0 0 0 0 0 1 1 0 0 0];
                        sent.B = [1 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 1 0 0 0 1 1 0 0 0 1 1 0 0 1 0 1 0 1 0 0 1 1 0 0 0];
                        sent.V = [1 0 1 0 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 1 0 1 1 1 0 0 1 1 0 0 1 1 0 0 0];
                    else
                        if ~isempty(strfind(imported_excel,'Scenario3B'))
                            disp('--->Scenario 3 (User B):');
                            found_OOK.inicio = 951;
                            found_MAN.inicio = 951;
                            found_OOK.fim = 2012;
                            found_MAN.fim = 3075;
                            sent.R = [1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 0 0 1 0 0 0 0 1 0 1 0 0 0 1 1 0 0 1 0 1 0 0 0];
                            sent.G = [1 0 1 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 1 0 0 0 0 1 0 0 0 0 1 0 1 1 0 1 0 0 0 0 1 0 1 0 0 0];
                            sent.B = [1 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 1 0 0 0 0 0 1 0 0 0 1 0 1 1 1 0 1 0 1 0 1 0 1 0 0 0];
                            sent.V = [1 0 1 0 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 1 0 0 0 1 1 0 0 1 0 0 1 1 0 1 0 1 0 0 0];
                        else
                            error('Could not determine which scenario was imported!');
                        end
                    end
                end
            end
        end
        
        %% RAW MEASUREMENTS
        
        %OOK:
        Time_OOK = raw_excel(:,1)'*1000;
        R_OOK = raw_excel(:,2)';
        G_OOK = raw_excel(:,3)';
        B_OOK = raw_excel(:,4)';
        V_OOK = raw_excel(:,5)';
        MUX_OOK = raw_excel(:,6)';
        parity_OOK = raw_excel(:,7)';
        figure('name','Raw Measurements - OOK')
        plot(Time_OOK,MUX_OOK); axis tight; hold on;
        stairs(Time_OOK,R_OOK,'r'); axis tight; hold on;
        stairs(Time_OOK,G_OOK,'g'); axis tight; hold on;
        stairs(Time_OOK,B_OOK,'b'); axis tight; hold on;
        stairs(Time_OOK,V_OOK,'m'); axis tight; hold on;
        ylim([0 9])
        xlabel('Time [ms]')
        ylabel('Amplitude')
        legend('MUX','R','G','B','V','Location','north','NumColumns',5);
        set(gca,'FontSize',15);
        
        %MANCHESTER:
        raw_excel = readmatrix(imported_excel,'Sheet','MAN');
        [excel_rows,excel_columns] = size(raw_excel);
        Time_MAN = raw_excel(:,1)'*1000;
        R_MAN = raw_excel(:,2)';
        G_MAN = raw_excel(:,3)';
        B_MAN = raw_excel(:,4)';
        V_MAN = raw_excel(:,5)';
        MUX_MAN = raw_excel(:,6)';
        parity_MAN = raw_excel(:,7)';
        figure('name','Raw Measurements - Manchester')
        plot(Time_MAN,MUX_MAN); axis tight; hold on;
        stairs(Time_MAN,R_MAN,'r'); axis tight; hold on;
        stairs(Time_MAN,G_MAN,'g'); axis tight; hold on;
        stairs(Time_MAN,B_MAN,'b'); axis tight; hold on;
        stairs(Time_MAN,V_MAN,'m'); axis tight; hold on;
        ylim([0 9])
        %xlim([951 3075])
        xlabel('Time [ms]')
        ylabel('Amplitude')
        legend('MUX','R','G','B','V','Location','north','NumColumns',5);
        set(gca,'FontSize',15);
        
        
%         figure('name','Cap Behaviour OOK DELETE LATER')
%         subplot(3,1,1)
%         stairs(Time_OOK,R_OOK,'r','LineWidth',1.5); axis tight; hold on;
%         stairs(Time_OOK,G_OOK,'g','LineWidth',1.5); axis tight; hold on;
%         stairs(Time_OOK,B_OOK,'b','LineWidth',1.5); axis tight; hold on;
%         stairs(Time_OOK,V_OOK,'m','LineWidth',1.5); axis tight; hold on;
%         ylim([6 9])
%         xlim([4.7 5.25])
%         yticks([6.25 6.75 7.25 7.75])
%         legend('R','G','B','V','Location','northwest','NumColumns',4)
%         xlabel('Time [ms]')
%         ylabel('Emitted Signals (LEDs)')
%         subplot(3, 1, [2 3])
%         plot(Time_OOK,MUX_OOK,'LineWidth',1.5); axis tight; hold on;
%         xlim([4.7 5.25])
%         ylim([0 6])
%         xlabel('Time [ms]')
%         ylabel('Received Signal (Photodiode)')
%         set(gcf, 'Position',  [100, 100, 800, 600])
%         legend('MUX Signal','Location','northwest')
%         
%         figure('name','Cap Behaviour MAN DELETE LATER')
%         subplot(3,1,1)
%         stairs(Time_MAN,R_MAN,'r','LineWidth',1.5); axis tight; hold on;
%         stairs(Time_MAN,G_MAN,'g','LineWidth',1.5); axis tight; hold on;
%         stairs(Time_MAN,B_MAN,'b','LineWidth',1.5); axis tight; hold on;
%         stairs(Time_MAN,V_MAN,'m','LineWidth',1.5); axis tight; hold on;
%         ylim([6 9])
%         xlim([4.615 5.6])
%         yticks([6.25 6.75 7.25 7.75])
%         legend('R','G','B','V','Location','northwest','NumColumns',4)
%         xlabel('Time [ms]')
%         ylabel('Emitted Signals (LEDs)')
%         subplot(3, 1, [2 3])
%         plot(Time_MAN,MUX_MAN,'LineWidth',1.5); axis tight; hold on;
%         xlim([4.615 5.6])
%         ylim([0 6])
%         xlabel('Time [ms]')
%         ylabel('Received Signal (Photodiode)')
%         set(gcf, 'Position',  [100, 100, 800, 600])
%         legend('MUX Signal','Location','northwest')
        
        %% OOK
        disp('<strong>[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[ OOK ]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]</strong>')
              
        sample_time = Time_OOK(2);
        
        found_OOK_time = Time_OOK(1:length(found_OOK.inicio:found_OOK.fim));
        found_OOK_MUX = MUX_OOK(found_OOK.inicio:found_OOK.fim);
        R_OOK = R_OOK(found_OOK.inicio:found_OOK.fim);
        G_OOK = G_OOK(found_OOK.inicio:found_OOK.fim);
        B_OOK = B_OOK(found_OOK.inicio:found_OOK.fim);
        V_OOK = V_OOK(found_OOK.inicio:found_OOK.fim);
        found_OOK_parity = parity_OOK(found_OOK.inicio:found_OOK.fim);
        
        %DELETE LATER!<-----------------------
        figure('name','Extra Synch OOK')
        plot(Time_OOK,MUX_OOK); axis tight; hold on;
        plot(Time_OOK(found_OOK.inicio:found_OOK.fim),MUX_OOK(found_OOK.inicio:found_OOK.fim),'LineWidth',1); axis tight; hold on;
        rectangle('Position',[Time_OOK(found_OOK.inicio) 0 Time_OOK(found_OOK.fim-found_OOK.inicio) 5.5],'EdgeColor','#D95319')
        ylim([0 6.9])
        xlabel('Time [ms]')
        ylabel('Amplitude')
        legend('MUX Signal','Data Frame','Location','north','NumColumns',2);
        set(gca,'FontSize',15);
        lol=1;
        figure('name','Extra Synch MAN')
        plot(Time_MAN,MUX_MAN); axis tight; hold on;
        plot(Time_MAN(found_MAN.inicio:found_MAN.fim),MUX_MAN(found_MAN.inicio:found_MAN.fim),'LineWidth',1); axis tight; hold on;
        rectangle('Position',[Time_MAN(found_MAN.inicio) 0 Time_MAN(found_MAN.fim-found_MAN.inicio) 5.5],'EdgeColor','#D95319')
        ylim([0 6.9])
        xlabel('Time [ms]')
        ylabel('Amplitude')
        legend('MUX Signal','Data Frame','Location','north','NumColumns',2);
        set(gca,'FontSize',15);
        lol=1;
        %DON'T DELETE PAST THIS POINT!
        
        %Removes extra samples from what was imported to ensure constant
        %samples per bit:
        bad_idxs_OOK = [17 50 83 116 149 182 215 216 249 282 315 348 381 382 415 448 481 514 547 548 581 614 631 664 697 714 747 796 797 830 863 880 913 946 963 996 1061 1062];
        found_OOK_time(bad_idxs_OOK) = [];
        found_OOK_MUX(bad_idxs_OOK) = [];
        R_OOK(bad_idxs_OOK) = [];
        G_OOK(bad_idxs_OOK) = [];
        B_OOK(bad_idxs_OOK) = [];
        V_OOK(bad_idxs_OOK) = [];
        found_OOK_parity(bad_idxs_OOK) = [];
        OOK_time_1024 = [0:sample_time:sample_time*(1024-1)];
        OOK_time_64 = [0:sample_time*16:sample_time*(1024-1)];
        samples_per_bit = (length(found_OOK_MUX)/64);
        
        figure('name','Found Frame - OOK')
        multiplier = 1; %OOK
        subplot(2,1,1)
        stairs(OOK_time_1024,R_OOK,'r','LineWidth',1.5); axis tight; hold on;
        stairs(OOK_time_1024,G_OOK,'g','LineWidth',1.5); axis tight; hold on;
        stairs(OOK_time_1024,B_OOK,'b','LineWidth',1.5); axis tight; hold on;
        stairs(OOK_time_1024,V_OOK,'m','LineWidth',1.5); axis tight; hold on;
        xline(OOK_time_1024(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(5*samples_per_bit+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(37*samples_per_bit+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(41*samples_per_bit+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(45*samples_per_bit+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(49*samples_per_bit+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(53*samples_per_bit+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(57*samples_per_bit+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(61*samples_per_bit+1),'--',{'PL'},'LabelOrientation','Horizontal');
        ylim([6 8+0.5])
        yticks([6.25 6.75 7.25 7.75])
        yticklabels({'V','B','G','R'})
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Emitted Signals (LEDs)') 
        
        subplot(2,1,2)
        %found_OOK_parity = found_OOK_parity./max(found_OOK_MUX); %Normalizado
        found_OOK_parity = found_OOK_parity./max(found_OOK_parity); %Normalizado
        %found_OOK_parity = found_OOK_parity*7;
        found_OOK_parity = found_OOK_parity*14.5;
        %figure; plot(found_OOK_parity);title('OOK Parity Signal')
        found_OOK_MUX = found_OOK_MUX./max(found_OOK_MUX); %Normalizado
        found_OOK_MUX = found_OOK_MUX*15;
 
        %plot(OOK_time_1024,found_OOK_MUX); axis tight; hold on;
        %plot(found_OOK_MUX); axis tight; hold on;
        
        temp = [1:length(found_OOK_MUX)];
        primeiros = temp(1:samples_per_bit:end);
        ultimos = temp(samples_per_bit:samples_per_bit:end);
        mux_corrigido = [];
        parity_corrigido = [];
        for i = 1:length(primeiros)
            %mux_corrigido(i) = mean(found_OOK_MUX(primeiros(i):ultimos(i)));
            mux_corrigido(i) = round(found_OOK_MUX(ultimos(i)));%<---------------------
            %parity_corrigido(i) = mean(found_OOK_parity(primeiros(i):ultimos(i)));
            parity_corrigido(i) = round(found_OOK_parity(ultimos(i)));%<-----------------
            %mux_corrigido(i) = round(mean(found_OOK_MUX(ultimos(i)-3:ultimos(i))));
            %parity_corrigido(i) = round(mean(found_OOK_parity(ultimos(i)-3:ultimos(i))));
        end
        mux_corrigido = round(mux_corrigido);
        parity_corrigido = round(parity_corrigido);%round
        %parity_corrigido = round_even(parity_corrigido);

        bit_time_x_corrigido = [0:DeltaT:(DeltaT*length(mux_corrigido))-DeltaT];
        plot(OOK_time_1024,found_OOK_MUX,'LineWidth',1); axis tight; hold on;
        stairs(OOK_time_64,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
        xline(OOK_time_1024(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(5*samples_per_bit+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(37*samples_per_bit+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(41*samples_per_bit+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(45*samples_per_bit+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(49*samples_per_bit+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(53*samples_per_bit+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(57*samples_per_bit+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(61*samples_per_bit+1),'--',{'PL'},'LabelOrientation','Horizontal');
        yticks(linspace(0,15,16))
        yticklabels({'0000','0001','0010','0011','0100','0101','0110','0111',...
            '1000','1001','1010','1011','1100','1101','1110','1111'})
        ylim([0 15+2.5])
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Received Signal (Photodiode)')
        %set(gcf, 'Position',  [100, 100, 800, 600])
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1;
        
        %DECODE RECEIVED BITS FROM MUX
        received.R = zeros(1,length(mux_corrigido));
        received.G = zeros(1,length(mux_corrigido));
        received.B = zeros(1,length(mux_corrigido));
        received.V = zeros(1,length(mux_corrigido));
        for i = 1:length(mux_corrigido)
            actual = mux_corrigido(i);
            switch actual
                case 0
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 1
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 2
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 3
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 1;
                case 4
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 5
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 6
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 7
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 1;
                case 8
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 9
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 10
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 11
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 1;
                case 12
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 13
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 14
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 15
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 1;
            end
        end
        confirmation_received = size([received.R; received.G; received.B; received.V]);
        %disp([num2str(confirmation_received(2)),' x4 bits were received.']);
        %disp('------------------ (OOK) Decoded Real Transmission -----------------')
        tfm_navdata(received);
        
        %BER
        if BER_FLAG
            %disp('---------------------------- (OOK) BER ------------------------------')
            bits_errados.R = sum(xor(received.R,sent.R(1,:)));
            bits_errados.G = sum(xor(received.G,sent.G(1,:)));
            bits_errados.B = sum(xor(received.B,sent.B(1,:)));
            bits_errados.V = sum(xor(received.V,sent.V(1,:)));
            bits_errados.total = bits_errados.R+bits_errados.G+bits_errados.B+bits_errados.V;
            numero_bits_total = length(sent.R)+length(sent.G)+length(sent.B)+length(sent.V);
            BER = (bits_errados.total/numero_bits_total);
            disp(['',num2str(bits_errados.total),' wrong bit(s) (BER = ',num2str(BER*100),'%)']);
            %Of which:
            disp([num2str(bits_errados.R),' of which came from the red emitter.']);
            disp([num2str(bits_errados.G),' of which came from the green emitter.']);
            disp([num2str(bits_errados.B),' of which came from the blue emitter.']);
            disp([num2str(bits_errados.V),' of which came from the violet emitter.']);
        end
        
        disp('<strong>[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[ OOK (w/parity) ]]]]]]]]]]]]]]]]]]]]]]</strong>')
        
        figure('name','Found Frame - OOK (w/ parity)')
        subplot(2,1,1)
        stairs(OOK_time_1024,R_OOK,'r','LineWidth',1.5); axis tight; hold on;
        stairs(OOK_time_1024,G_OOK,'g','LineWidth',1.5); axis tight; hold on;
        stairs(OOK_time_1024,B_OOK,'b','LineWidth',1.5); axis tight; hold on;
        stairs(OOK_time_1024,V_OOK,'m','LineWidth',1.5); axis tight; hold on;
        xline(OOK_time_1024(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(5*samples_per_bit+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(37*samples_per_bit+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(41*samples_per_bit+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(45*samples_per_bit+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(49*samples_per_bit+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(53*samples_per_bit+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(57*samples_per_bit+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(OOK_time_1024(61*samples_per_bit+1),'--',{'PL'},'LabelOrientation','Horizontal');
        ylim([6 8+0.5])
        yticks([6.25 6.75 7.25 7.75])
        yticklabels({'V','B','G','R'})
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Emitted Signals (LEDs)')
              
        subplot(2,1,2)
        %stairs(OOK_time_64,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
        %stairs(OOK_time_64,parity_corrigido,'LineWidth',1.5); axis tight; hold on;
        plot(OOK_time_1024,found_OOK_MUX,'LineWidth',1); axis tight; hold on;
        %stairs(OOK_time_64,parity_corrigido,'LineWidth',1.5); axis tight; hold on;
        %stairs(OOK_time_64,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
        %stairs(OOK_time_64,parity_corrigido,'LineWidth',1.5); axis tight; hold on;
        xline(OOK_time_64(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(5+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(37+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(41+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(45+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(49+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(53+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(57+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(61+1),'--',{'PL'},'LabelOrientation','Horizontal');
        
        [received,decoded4plot] = tfm_parity_decoder(parity_corrigido,mux_corrigido);
        stairs(OOK_time_64,decoded4plot,'LineWidth',1.5); axis tight; hold on;
        tfm_navdata(received);
        yticks(linspace(0,15,16))
        yticklabels({'0000','0001','0010','0011','0100','0101','0110','0111',...
            '1000','1001','1010','1011','1100','1101','1110','1111'})
        ylim([0 15+2.5])
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Received Signal (Photodiode)')
        %set(gcf, 'Position',  [100, 100, 800, 600])
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1;
        
        figure('name','Measured OOK Parity signal')
        plot(OOK_time_1024,found_OOK_parity); axis tight; hold on;
        stairs(OOK_time_64,parity_corrigido,'LineWidth',1.5); axis tight; hold on;
        ylim([-1 15+1.5])
        %ylim([-1 15])
        xlabel('Time [ms]')
        ylabel('Parity levels')
        yticks([0:2:14])
        yticklabels({'p_0','p_2','p_4','p_6','p_8','p_1_0','p_1_2','p_1_4'})
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xline(OOK_time_64(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(5+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(37+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(41+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(45+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(49+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(53+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(57+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(OOK_time_64(61+1),'--',{'PL'},'LabelOrientation','Horizontal');
        set(gcf, 'Position',  [100, 100, 800, 300])
        %ylim([-1 15])
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1;
        
        %BER
        if BER_FLAG
            %disp('---------------------------- (OOK w/ parity) BER --------------------')
            bits_errados.R = sum(xor(received.R,sent.R(1,:)));
            bits_errados.G = sum(xor(received.G,sent.G(1,:)));
            bits_errados.B = sum(xor(received.B,sent.B(1,:)));
            bits_errados.V = sum(xor(received.V,sent.V(1,:)));
            bits_errados.total = bits_errados.R+bits_errados.G+bits_errados.B+bits_errados.V;
            numero_bits_total = length(sent.R)+length(sent.G)+length(sent.B)+length(sent.V);
            %BER = (bits_errados.total/numero_bits_total)*100;
            %disp([num2str(bits_errados.total),' wrong bits (BER = ',num2str(BER),'%)']);
            BER = (bits_errados.total/numero_bits_total);
            disp(['',num2str(bits_errados.total),' wrong bit(s) (BER = ',num2str(BER*100),'%)']);
            disp([num2str(bits_errados.R),' of which came from the red emitter.']);
            disp([num2str(bits_errados.G),' of which came from the green emitter.']);
            disp([num2str(bits_errados.B),' of which came from the blue emitter.']);
            disp([num2str(bits_errados.V),' of which came from the violet emitter.']);
        end
        
%         suposto = zeros(1,length(sent.R));
%         suposto2 = suposto;
%         for i = 1:length(sent.R)
%             %
%             suposto(i) = sent.R(i)*8+sent.G(i)*4+sent.B(i)*2+sent.V(i);
%             switch suposto(i)
%                 case 0
%                     suposto2(i) = 0;
%                 case 1
%                     suposto2(i) = 14;
%                 case 2
%                     suposto2(i) = 10;
%                 case 3
%                     suposto2(i) = 4;
%                 case 4
%                     suposto2(i) = 6;
%                 case 5
%                     suposto2(i) = 8;
%                 case 6
%                     suposto2(i) = 12;
%                 case 7
%                     suposto2(i) = 2;
%                 case 8
%                     suposto2(i) = 12;
%                 case 9
%                     suposto2(i) = 2;
%                 case 10
%                     suposto2(i) = 6;
%                 case 11
%                     suposto2(i) = 8;
%                 case 12
%                     suposto2(i) = 10;
%                 case 13
%                     suposto2(i) = 4;
%                 case 14
%                     suposto2(i) = 0;
%                 case 15
%                     suposto2(i) = 14;
%                     
%             end
%         end
%         %stairs(OOK_time_64,suposto2,'LineWidth',1.5); axis tight; hold on;
%         ylim([-0.5 16.5])
%         %clc;
%         parity_corrigido
%         suposto2
%         parity_diference = 0;
%         for i = 1:length(suposto2)
%             if suposto2(i)~=parity_corrigido(i)
%                 parity_diference = parity_diference+1;
%             end
%         end
%         parity_diference
        
        figure('name','OOK - Before and After Parity')
        suposto = sent.R(1,:)*8+sent.G(1,:)*4+sent.B(1,:)*2+sent.V(1,:);
        OOK_erros = (suposto~=mux_corrigido).*mux_corrigido;
        OOKP_erros = (suposto~=decoded4plot).*decoded4plot;
        OOK_erros(OOK_erros==0)=-1;
        OOKP_erros(OOKP_erros==0)=-1;
        subplot(2,1,1)
        bar(mux_corrigido+1); axis tight; hold on; title('Before Parity (OOK)')
        text(1:length(mux_corrigido),mux_corrigido+1,num2str(mux_corrigido'),'vert','bottom','horiz','center');
        bar(OOK_erros+1,'r'); axis tight; hold on;
        ylim([0 18.5])
        xline(0,'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(5.5,'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(37.5,'--',{'x'},'LabelOrientation','Horizontal');
        xline(41.5,'--',{'y'},'LabelOrientation','Horizontal');
        xline(45.5,'--',{'z'},'LabelOrientation','Horizontal');
        xline(49.5,'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(53.5,'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(57.5,'--',{'δ'},'LabelOrientation','Horizontal');
        xline(61.5,'--',{'PL'},'LabelOrientation','Horizontal');
        xticks([1 5 21 37 41 45 49 53 57 61 64])
        yticks([0 5 10 15]+1)
        yticklabels({'0','5','10','15'})
        xlabel('Frame bit')
        ylabel('Decoded level')
        
        subplot(2,1,2)
        bar(decoded4plot+1); axis tight; hold on; title('After Parity (OOK)')
        text(1:length(decoded4plot),decoded4plot+1,num2str(decoded4plot'),'vert','bottom','horiz','center');
        bar(OOKP_erros+1,'r'); axis tight; hold on;
%         P_affected = zeros(1,length(OOKP_erros));
%         P_fixed = P_affected;
%         P_ruined = P_affected;
%         %P_affected = isequal
%         for i = 1:length(P_affected)
%             if OOK_erros(i)~=OOKP_erros(i)
%                 P_affected(i) = 1;
%             end
%             if P_affected(i) == 1
%                 if decoded4plot(i)==suposto(i)
%                     P_fixed(i) = decoded4plot(i);
%                 end
%                 if (mux_corrigido(i) == suposto(i)) && (decoded4plot(i) ~= suposto(i))
%                     P_ruined(i) = decoded4plot(i);
%                 end
%             end
%         end
%         P_fixed(P_fixed==0)=-1;
%         P_ruined(P_ruined==0)=-1;
%         bar(P_fixed+1,'FaceColor',[0.466 0.674 0.188]); axis tight; hold on;
%         bar(P_ruined+1,'k'); axis tight; hold on;
        ylim([0 18.5])
        xline(0,'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(5.5,'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(37.5,'--',{'x'},'LabelOrientation','Horizontal');
        xline(41.5,'--',{'y'},'LabelOrientation','Horizontal');
        xline(45.5,'--',{'z'},'LabelOrientation','Horizontal');
        xline(49.5,'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(53.5,'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(57.5,'--',{'δ'},'LabelOrientation','Horizontal');
        xline(61.5,'--',{'PL'},'LabelOrientation','Horizontal');
        xticks([1 5 21 37 41 45 49 53 57 61 64])
        yticks([0 5 10 15]+1)
        yticklabels({'0','5','10','15'})
        xlabel('Frame bit')
        ylabel('Decoded level')
        %set(gcf, 'Position',  [100, 100, 1250, 600])%800 600
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1; 
        
        %% MANCHESTER
        disp('<strong>[[[[[[[[[[[[[[[[[[[[[[[[[[[ Manchester ]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]</strong>')
        
        sample_time = Time_MAN(2);
        
        found_MAN_time = Time_MAN(1:length(found_MAN.inicio:found_MAN.fim));
        found_MAN_MUX = MUX_MAN(found_MAN.inicio:found_MAN.fim);
        R_MAN = R_MAN(found_MAN.inicio:found_MAN.fim);
        G_MAN = G_MAN(found_MAN.inicio:found_MAN.fim);
        B_MAN = B_MAN(found_MAN.inicio:found_MAN.fim);
        V_MAN = V_MAN(found_MAN.inicio:found_MAN.fim);
        found_MAN_parity = parity_MAN(found_MAN.inicio:found_MAN.fim);
        
        %Removes extra samples from what was imported to ensure constant
        %samples per bit:
        bad_idxs_MAN = [17 50 83 116 149 182 199 216 249 266 299 332 365 382 415 432 465 498 531 548];
        bad_idxs_MAN = [bad_idxs_MAN 581 598 631 664 697 714 747 780 797 830 863 880 913 946 963 996 1029 1046];
        bad_idxs_MAN = [bad_idxs_MAN 1079 1112 1129 1162 1195 1212 1245 1262 1311 1328 1361 1378 1411 1444 1461];
        bad_idxs_MAN = [bad_idxs_MAN 1494 1527 1544 1577 1594 1627 1676 1693 1710 1743 1760 1809 1826 1859 1876];
        bad_idxs_MAN = [bad_idxs_MAN 1909 1926 1959 1992 2025 2042 2075 2092 2125];
        found_MAN_time(bad_idxs_MAN) = [];
        found_MAN_MUX(bad_idxs_MAN) = [];
        R_MAN(bad_idxs_MAN) = [];
        G_MAN(bad_idxs_MAN) = [];
        B_MAN(bad_idxs_MAN) = [];
        V_MAN(bad_idxs_MAN) = [];
        found_MAN_parity(bad_idxs_MAN) = [];
        %MAN_time_1024 = [0:sample_time:sample_time*(1024-1)];
        %MAN_time_64 = [0:sample_time*16:sample_time*(1024-1)];
        MAN_time_128 = [0:sample_time*16:sample_time*(2048-1)];
        MAN_time_2048 = [0:sample_time:sample_time*(2048-1)];
        
        samples_per_bit = (length(found_MAN_MUX)/(64*2));
        %disp([num2str(samples_per_bit),' samples per bit, in Manchester.']);
        
        figure('name','Found Frame - MAN')
        multiplier = 2; %MAN
        subplot(2,1,1)
        stairs(MAN_time_2048,R_MAN,'r','LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_2048,G_MAN,'g','LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_2048,B_MAN,'b','LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_2048,V_MAN,'m','LineWidth',1.5); axis tight; hold on;
        xline(MAN_time_2048(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(5*2*samples_per_bit),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(37*2*samples_per_bit),'--',{'x'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(41*2*samples_per_bit),'--',{'y'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(45*2*samples_per_bit),'--',{'z'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(49*2*samples_per_bit),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(53*2*samples_per_bit),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(57*2*samples_per_bit),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(61*2*samples_per_bit),'--',{'PL'},'LabelOrientation','Horizontal');
        ylim([6 8+0.5])
        yticks([6.25 6.75 7.25 7.75])
        yticklabels({'V','B','G','R'})
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Emitted Signals (LEDs)')
        
        %xlim([0 11])
        %legend('R','G','B','V','Location','east','NumColumns',1)
        %legend('boxoff')
        
        subplot(2,1,2)
        found_MAN_parity = found_MAN_parity./max(found_MAN_MUX); %Normalizado
        %found_MAN_parity = found_MAN_parity./max(found_MAN_parity); %Normalizado
        found_MAN_parity = found_MAN_parity*15;
        found_MAN_MUX = found_MAN_MUX./max(found_MAN_MUX); %Normalizado
        found_MAN_MUX = found_MAN_MUX*15;%15?
 
        %plot(OOK_time_1024,found_OOK_MUX); axis tight; hold on;
        %plot(found_OOK_MUX); axis tight; hold on;
        plot(MAN_time_2048,found_MAN_MUX); axis tight; hold on;
        
        temp = [1:length(found_MAN_MUX)];
        primeiros = temp(1:samples_per_bit:end);
        ultimos = temp(samples_per_bit:samples_per_bit:end);
        mux_corrigido = [];
        parity_corrigido = [];
        for i = 1:length(primeiros)
            %mux_corrigido(i) = mean(found_MAN_MUX(primeiros(i):ultimos(i)));
            mux_corrigido(i) = round(found_MAN_MUX(ultimos(i)));
            %parity_corrigido(i) = mean(found_MAN_parity(primeiros(i):ultimos(i)));
            parity_corrigido(i) = round(found_MAN_parity(ultimos(i)));
        end
        mux_corrigido = round(mux_corrigido);
        parity_corrigido = round(parity_corrigido);

        bit_time_x_corrigido = [0:DeltaT:(DeltaT*length(mux_corrigido))-DeltaT];
        %stairs(bit_time_x_corrigido,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_128,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
        xline(MAN_time_128(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(5*2+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(37*2+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(41*2+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(45*2+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(49*2+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(53*2+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(57*2+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(61*2+1),'--',{'PL'},'LabelOrientation','Horizontal');
        yticks(linspace(0,15,16))
        yticklabels({'0000','0001','0010','0011','0100','0101','0110','0111',...
            '1000','1001','1010','1011','1100','1101','1110','1111'})
        ylim([0 15+2.5])
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Received Signal (Photodiode)')
        %set(gcf, 'Position',  [100, 100, 800, 600])
        %xlim([0 11])
        %legend('Measured','Decoded','Location','east','NumColumns',1)
        %legend('boxoff')
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1;
        
        
        %DECODE RECEIVED BITS FROM MUX
        received.R = zeros(1,length(mux_corrigido));
        received.G = zeros(1,length(mux_corrigido));
        received.B = zeros(1,length(mux_corrigido));
        received.V = zeros(1,length(mux_corrigido));
        for i = 1:length(mux_corrigido)
            actual = mux_corrigido(i);
            switch actual
                case 0
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 1
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 2
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 3
                    received.R(i) = 0;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 1;
                case 4
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 5
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 6
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 7
                    received.R(i) = 0;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 1;
                case 8
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 9
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 10
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 11
                    received.R(i) = 1;
                    received.G(i) = 0;
                    received.B(i) = 1;
                    received.V(i) = 1;
                case 12
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 0;
                case 13
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 0;
                    received.V(i) = 1;
                case 14
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 0;
                case 15
                    received.R(i) = 1;
                    received.G(i) = 1;
                    received.B(i) = 1;
                    received.V(i) = 1;
            end
        end
        
        %ONCE THE BITS HAVE BEEN DECODED FROM THE MUX, WHEN USING MANCHESTER,
        %THE BITS NEED TO BE DEMODULATED BACK TO DATA BITS
        received_MAN2OOK.R = zeros(1,length(received.R)/2);
        received_MAN2OOK.G = zeros(1,length(received.G)/2);
        received_MAN2OOK.B = zeros(1,length(received.B)/2);
        received_MAN2OOK.V = zeros(1,length(received.V)/2);
        ii = 1;
        for i = 1:2:length(received.R)
            received_MAN2OOK.R(ii) = received.R(i);
            received_MAN2OOK.G(ii) = received.G(i);
            received_MAN2OOK.B(ii) = received.B(i);
            received_MAN2OOK.V(ii) = received.V(i);
            ii = ii+1;
        end
        received.R = received_MAN2OOK.R;
        received.G = received_MAN2OOK.G;
        received.B = received_MAN2OOK.B;
        received.V = received_MAN2OOK.V;
        confirmation_received = size([received.R; received.G; received.B; received.V]);
        %disp([num2str(confirmation_received(2)),' x4 bits were received.']);
        %disp('-------------- (Manchester) Decoded Real Transmission --------------')
        tfm_navdata(received);
        
        figure('name','Measured Manchester Parity signal')
        plot(MAN_time_2048,found_MAN_parity); axis tight; hold on;
        stairs(MAN_time_128,parity_corrigido,'LineWidth',1.5); axis tight; hold on;
        %ylim([-1 15])
        xlabel('Time [ms]')
        ylabel('Parity levels')
        %yticks(linspace(0,15,16))
        yticks([0:2:14])
        yticklabels({'p_0','p_2','p_4','p_6','p_8','p_1_0','p_1_2','p_1_4'})
        ylim([-1 15+1.5])
        xline(MAN_time_128(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(5*2+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(37*2+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(41*2+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(45*2+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(49*2+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(53*2+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(57*2+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(61*2+1),'--',{'PL'},'LabelOrientation','Horizontal');
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        %set(gcf, 'Position',  [100, 100, 800, 300])
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1;
        
        %BER
        if BER_FLAG
            %disp('------------------------ (Manchester) BER ---------------------------')
            bits_errados.R = sum(xor(received.R,sent.R(1,:)));
            bits_errados.G = sum(xor(received.G,sent.G(1,:)));
            bits_errados.B = sum(xor(received.B,sent.B(1,:)));
            bits_errados.V = sum(xor(received.V,sent.V(1,:)));
            bits_errados.total = bits_errados.R+bits_errados.G+bits_errados.B+bits_errados.V;
            numero_bits_total = length(sent.R)+length(sent.G)+length(sent.B)+length(sent.V);
            BER = (bits_errados.total/numero_bits_total);
            disp(['',num2str(bits_errados.total),' wrong bit(s) (BER = ',num2str(BER*100),'%)']);
            disp([num2str(bits_errados.R),' of which came from the red emitter.']);
            disp([num2str(bits_errados.G),' of which came from the green emitter.']);
            disp([num2str(bits_errados.B),' of which came from the blue emitter.']);
            disp([num2str(bits_errados.V),' of which came from the violet emitter.']);
        end
        
        disp('<strong>[[[[[[[[[[[[[[[[[[[[[[[[[[[ Manchester (w/parity) ]]]]]]]]]]]]]]]]]]]</strong>')
        
        figure('name','Found Frame - MAN (w/ parity)')
        subplot(2,1,1)
        stairs(MAN_time_2048,R_MAN,'r','LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_2048,G_MAN,'g','LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_2048,B_MAN,'b','LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_2048,V_MAN,'m','LineWidth',1.5); axis tight; hold on;
        xline(MAN_time_2048(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(5*2*samples_per_bit),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(37*2*samples_per_bit),'--',{'x'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(41*2*samples_per_bit),'--',{'y'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(45*2*samples_per_bit),'--',{'z'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(49*2*samples_per_bit),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(53*2*samples_per_bit),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(57*2*samples_per_bit),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(MAN_time_2048(61*2*samples_per_bit),'--',{'PL'},'LabelOrientation','Horizontal');
        ylim([6 8+0.5])
        yticks([6.25 6.75 7.25 7.75])
        yticklabels({'V','B','G','R'})
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Emitted Signals (LEDs)')
        
        
        subplot(2,1,2)
        plot(MAN_time_2048,found_MAN_MUX); axis tight; hold on;
        %stairs(MAN_time_128,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
        %stairs(MAN_time_128,parity_corrigido,'LineWidth',1.5); axis tight; hold on;
        yticks(linspace(0,15,16))
        yticklabels({'0000','0001','0010','0011','0100','0101','0110','0111',...
            '1000','1001','1010','1011','1100','1101','1110','1111'})
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Received Signal (Photodiode)')
        %set(gcf, 'Position',  [100, 100, 800, 600])
        
        
        [received,decoded4plot] = tfm_parity_decoder(parity_corrigido,mux_corrigido);
        %stairs(OOK_time_64,decoded4plot,'LineWidth',1.5); axis tight; hold on;
        stairs(MAN_time_128,decoded4plot,'LineWidth',1.5); axis tight; hold on;
        ylim([0 15+2.5])
        xline(MAN_time_128(1),'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(5*2+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(37*2+1),'--',{'x'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(41*2+1),'--',{'y'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(45*2+1),'--',{'z'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(49*2+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(53*2+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(57*2+1),'--',{'δ'},'LabelOrientation','Horizontal');
        xline(MAN_time_128(61*2+1),'--',{'PL'},'LabelOrientation','Horizontal');
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1;
        
        
        %<-----
        %ONCE THE BITS HAVE BEEN DECODED FROM THE MUX, WHEN USING MANCHESTER,
        %THE BITS NEED TO BE DEMODULATED BACK TO DATA BITS
        received_MAN2OOK.R = zeros(1,length(received.R)/2);
        received_MAN2OOK.G = zeros(1,length(received.G)/2);
        received_MAN2OOK.B = zeros(1,length(received.B)/2);
        received_MAN2OOK.V = zeros(1,length(received.V)/2);
        ii = 1;
        for i = 1:2:length(received.R)
            received_MAN2OOK.R(ii) = received.R(i);
            received_MAN2OOK.G(ii) = received.G(i);
            received_MAN2OOK.B(ii) = received.B(i);
            received_MAN2OOK.V(ii) = received.V(i);
            ii = ii+1;
        end
        received.R = received_MAN2OOK.R;
        received.G = received_MAN2OOK.G;
        received.B = received_MAN2OOK.B;
        received.V = received_MAN2OOK.V;
        confirmation_received = size([received.R; received.G; received.B; received.V]);
        %disp([num2str(confirmation_received(2)),' x4 bits were received.']);
        %disp('-------------- (Manchester) Decoded Real Transmission --------------')
        tfm_navdata(received);
        %<-----
        %tfm_navdata(received);
        
        %BER
        if BER_FLAG
            %disp('---------------------------- (Manchester w/ parity) BER --------------------')
            bits_errados.R = sum(xor(received.R,sent.R(1,:)));
            bits_errados.G = sum(xor(received.G,sent.G(1,:)));
            bits_errados.B = sum(xor(received.B,sent.B(1,:)));
            bits_errados.V = sum(xor(received.V,sent.V(1,:)));
            bits_errados.total = bits_errados.R+bits_errados.G+bits_errados.B+bits_errados.V;
            numero_bits_total = length(sent.R)+length(sent.G)+length(sent.B)+length(sent.V);
            BER = (bits_errados.total/numero_bits_total);
            disp(['',num2str(bits_errados.total),' wrong bit(s) (BER = ',num2str(BER*100),'%)']);
            disp([num2str(bits_errados.R),' of which came from the red emitter.']);
            disp([num2str(bits_errados.G),' of which came from the green emitter.']);
            disp([num2str(bits_errados.B),' of which came from the blue emitter.']);
            disp([num2str(bits_errados.V),' of which came from the violet emitter.']);
        end
        
        figure('name','Manchester - Before and After Parity')
        %[sinal_mod_out] = tfm_modulation(sinal_mod_in,mod_select,flag_plot)
        suposto = tfm_modulation(sent.R(1,:),'Manchester',0)*8+tfm_modulation(sent.G(1,:),'Manchester',0)*4+...
        tfm_modulation(sent.B(1,:),'Manchester',0)*2+tfm_modulation(sent.V(1,:),'Manchester',0);
        MAN_erros = (suposto~=mux_corrigido).*mux_corrigido;
        MANP_erros = (suposto~=decoded4plot).*decoded4plot;
        MAN_erros(MAN_erros==0)=-1;
        MANP_erros(MANP_erros==0)=-1;
        subplot(2,1,1)
        %bar(mux_corrigido); axis tight; hold on; title('Before Parity')
        bar(mux_corrigido(1:2:end)+1); axis tight; hold on; title('Before Parity (Manchester)')
        bar(MAN_erros(1:2:end)+1,'r'); axis tight; hold on;
        %text(1:length(mux_corrigido),mux_corrigido,num2str(mux_corrigido'),'vert','bottom','horiz','center');
        text(1:length(mux_corrigido)/2,mux_corrigido(1:2:end)+1,num2str(mux_corrigido(1:2:end)'),'vert','bottom','horiz','center');
        ylim([0 18.5])
        xline(0,'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(5.5,'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(37.5,'--',{'x'},'LabelOrientation','Horizontal');
        xline(41.5,'--',{'y'},'LabelOrientation','Horizontal');
        xline(45.5,'--',{'z'},'LabelOrientation','Horizontal');
        xline(49.5,'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(53.5,'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(57.5,'--',{'δ'},'LabelOrientation','Horizontal');
        xline(61.5,'--',{'PL'},'LabelOrientation','Horizontal');
        xticks([1 5 21 37 41 45 49 53 57 61 64])
        yticks([0 5 10 15]+1)
        yticklabels({'0','5','10','15'})
        xlabel('Frame bit')
        ylabel('Decoded level')
        
        subplot(2,1,2)
        %bar(decoded4plot); axis tight; hold on; title('After Parity')
        bar(decoded4plot(1:2:end)+1); axis tight; hold on; title('After Parity (Manchester)')
        bar(MANP_erros(1:2:end)+1,'r'); axis tight; hold on;
%         P_affected = zeros(1,length(MANP_erros));
%         P_fixed = P_affected;
%         P_ruined = P_affected;
%         %P_affected = isequal
%         for i = 1:length(P_affected)
%             if MAN_erros(i)~=MANP_erros(i)
%                 P_affected(i) = 1;
%             end
%             if P_affected(i) == 1
%                 if decoded4plot(i)==suposto(i)
%                     P_fixed(i) = decoded4plot(i);
%                 end
%                 if (mux_corrigido(i) == suposto(i)) && (decoded4plot(i) ~= suposto(i))
%                     P_ruined(i) = decoded4plot(i);
%                 end
%             end
%         end
%         P_fixed(P_fixed==0)=-1;
%         P_ruined(P_ruined==0)=-1;
%         bar(P_fixed(1:2:end)+1,'FaceColor','#10A625'); axis tight; hold on;
%         bar(P_ruined(1:2:end)+1,'k'); axis tight; hold on;
        %text(1:length(decoded4plot),decoded4plot,num2str(decoded4plot'),'vert','bottom','horiz','center');
        text(1:length(decoded4plot)/2,decoded4plot(1:2:end)+1,num2str(decoded4plot(1:2:end)'),'vert','bottom','horiz','center');
        ylim([0 18.5])
        xline(0,'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(5.5,'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(37.5,'--',{'x'},'LabelOrientation','Horizontal');
        xline(41.5,'--',{'y'},'LabelOrientation','Horizontal');
        xline(45.5,'--',{'z'},'LabelOrientation','Horizontal');
        xline(49.5,'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(53.5,'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(57.5,'--',{'δ'},'LabelOrientation','Horizontal');
        xline(61.5,'--',{'PL'},'LabelOrientation','Horizontal');
        xticks([1 5 21 37 41 45 49 53 57 61 64])
        yticks([0 5 10 15]+1)
        yticklabels({'0','5','10','15'})
        xlabel('Frame bit')
        ylabel('Decoded level')
        %set(gcf, 'Position',  [100, 100, 1250, 600])%800 600
        set(gcf, 'Position',  [100, 100, 1600, 600])
        lol=1;
        
        
    else
      error(['Not enough columns in imported excel file!',...
                ' The selected file has ',num2str(excel_columns),' columns, and the minimum is 12 (1x Time + 4x LED + 1x MUX) x2 modulations.']);
    end       
end

function y = round_even(x)
    y = 2*floor(x/2)+0;
end
