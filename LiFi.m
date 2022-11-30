function LiFi(Pt_R,Pt_G,Pt_B,Pt_V,raio_cm,lambda_r,lambda_g,lambda_b,lambda_v,...
    G_rx_r,G_rx_g,G_rx_b,G_rx_v,DeltaT,SR,SG,SB,SV,CM_SR,CM_SG,CM_SB,CM_SV,...
    FName1,FName2,FName3,OFFcount,CM_OFFcount,P_OFF,D_ON,...
    SR_D,SG_D,SB_D,SV_D,BER_FLAG,CC_FLAG,mod_select,parity_select,...
    capacitive_select,capacitive_howmuch,capacitive_samples,...
    imported_excel,...
    input_bits_R1,input_bits_G1,input_bits_B1,input_bits_V1)
clc;
format shortEng

if D_ON==1
    if length(SG_D)~=32 && (OFFcount==2  || OFFcount==3)
        error('ERRO: O Sinal Transmitido tem de ter 32 bits!')
    end
    %TXtoRX (FName1, SR_D, SG_D, SB_D, SV_D, DeltaT, BER_FLAG, CC_FLAG,imported_excel)
    %tfm_excel_decoder(imported_excel,samples_per_bit,DeltaT,BER_FLAG);
    tfm_excel_decoder_v3(imported_excel,DeltaT,BER_FLAG);
    
else
    %disp('ATENÇÃO: Descodificação "real" não activada!')
    
    % --- PARÂMETROS DE ENTRADA ---
    F_dB = 100;                                  %Factor de atenuação devido ao número de andares [dB] (Escritório)
    k = 0;                                       %Número de andares atravessados pela onda directa []
    W_dB = 100;                                  %Factor de atenuação devido às paredes [dB]
    file_name = 'piso_3_LEDs.bmp';               %Nome do ficheiro da planta
    raio_pixel=65;                               %Raio do LED em pixeis = 65 [pixel]
    px2d = (raio_cm/raio_pixel)*10^-2;           %Distância em metros a que correspode a 1 píxel = (0.03077*10^-2) [m]
    lambda_R=lambda_r*10^-9;                     %Comprimento de onda do LED(R)
    lambda_G=lambda_g*10^-9;                     %Comprimento de onda do LED(G)
    lambda_B=lambda_b*10^-9;                     %Comprimento de onda do LED(B)
    lambda_V=lambda_v*10^-9;                     %Comprimento de onda do LED(V)
    dim_sala= 138*px2d*10^2;                     %Dimensão da sala dim_sala x dim_sala [cm]
    teta3db=deg2rad(60);
    h_PH=1;
    %h_PH=0.01;
    h_LED=(raio_cm*10^-2)/tan(teta3db);
    
    %BITS ENVIADOS (PARA DETERMINAR A BER)
    %sent.R = SR;
    %sent.G = SG;
    %sent.B = SB;
    %sent.V = SV;
    sent.R = input_bits_R1';
    sent.G = input_bits_G1';
    sent.B = input_bits_B1';
    sent.V = input_bits_V1';
    
    if ((G_rx_r || G_rx_g || G_rx_b || G_rx_v)~=0 )
        G_Rx_R = 10*log10(G_rx_r);      %(5)    %Ganho de recepção do receptor móvel [dB]
        G_Rx_G = 10*log10(G_rx_g);      %(4)
        G_Rx_B = 10*log10(G_rx_b);      %(1.7)
        G_Rx_V = 10*log10(G_rx_v);      %(0.8)
    else
        G_Rx_R=G_rx_r;
        G_Rx_G=G_rx_g;
        G_Rx_B=G_rx_b;
        G_Rx_V=G_rx_v;
    end
    
    P_R=xor(xor(SV,SR),SB);
    P_G=xor(xor(SV,SR),SG);
    P_B=xor(xor(SV,SG),SB);
    P_V = zeros(3,length(P_R));%ROCHA
    
    Y_textP=[9.08 12.18 14.26];
    Y_textT=[14.26 12.18 9.08];
    
    % --- CÁLCULOS AUXILIARES ---
    planta = imread(file_name); %% reads a grayscale or color image from the file
    RGB.R = planta(:,:,1);
    RGB.G = planta(:,:,2);
    RGB.B = planta(:,:,3);
    [planta_y,planta_x] = size(RGB.B);
    
    %Indoor
    indoor = Indoor_Finder(RGB);
    
    % Procura os LEDs na planta
    LED_R_Matrix = RGB_finder(RGB,255,0,0).*100;
    LED_G_Matrix = RGB_finder(RGB,34,177,76).*200;
    LED_B_Matrix = RGB_finder(RGB,63,72,204).*300;
    LED_V_Matrix = RGB_finder(RGB,255,0,255).*400;
    LEDs_Matrix = LED_R_Matrix+LED_G_Matrix+LED_B_Matrix+LED_V_Matrix;
    LEDs_cores = unique(LEDs_Matrix);
    if  sum(LEDs_cores)==0
        error('ERRO: Não foi encontrada nenhuma antena na planta.');
    end
    
    %Procura as paredes na planta
    Wall_Matrix = RGB_finder(RGB, 0,0,0)+RGB_finder(RGB,45,45,45)+RGB_finder(RGB,237,28,36);
    
    %-------------------Redefine o tamanho da matriz indoor-------------------
    for yy = 1:planta_y
        for xx = 1:planta_x
            if indoor(yy,xx)==1
                Indoor_Matrix(yy,xx)=1;
                if Wall_Matrix(yy,xx)==1
                    Indoor_Wall_Matrix(yy,xx)=1;
                else
                    Indoor_Wall_Matrix(yy,xx)=0;
                end
            end
        end
    end
    
    size_Indoor=size(Indoor_Matrix);
    indoor_y=size_Indoor(1);
    indoor_x=size_Indoor(2);
    
    % -------------------------------DOWNLINK---------------------------------
    % ---------------RED LED--------------
    [LED_R_y, LED_R_x]=find(LEDs_Matrix==100);
    Coords_LED_R= [LED_R_y, LED_R_x]; %Coordenadas (y,x) de todos os LEDs verdes
    LED_R_max = size(Coords_LED_R);
    
    Matrix_Coords_Raio_R=zeros(indoor_y,indoor_x);
    dx_m_R=zeros(indoor_y,indoor_x,LED_R_max(1));
    d_R=zeros(indoor_y,indoor_x,LED_R_max(1));
    Ganho_tx_R=zeros(indoor_y,indoor_x,LED_R_max(1));
    nWalls=zeros(indoor_y,indoor_x,LED_R_max(1));
    L_dB_R=zeros(indoor_y,indoor_x,LED_R_max(1));
    link_budget_LED_R=zeros(indoor_y,indoor_x,LED_R_max(1));
    min_link_budget_LED_R=zeros(1,LED_R_max(1));
    
    
    for LED_R=1:LED_R_max(1)
        
        coord_LED_R=Coords_LED_R(LED_R,:); %Coordenada (y,x) de um LED vermelho
        p2 = coord_LED_R;
        for yy = 1:indoor_y
            for xx = 1:indoor_x
                p1=[yy,xx];
                if indoor(yy,xx)==1 %Se pertencer ao indoor
                    
                    dx_m_R(yy,xx,LED_R) = hypot(p2(2)-p1(2), p2(1)-p1(1))*px2d; %dd = sqrt((p2(2)-p1(2))^2+(p2(1)-p1(1))^2);
                    d_R(yy,xx,LED_R) = hypot(dx_m_R(yy,xx,LED_R), h_LED-h_PH);
                    Ganho_tx_R(yy,xx,LED_R)=GanhoTx(dx_m_R(yy,xx,LED_R),d_R(yy,xx,LED_R),Pt_R(LED_R),teta3db);
                    
                    if sum(p1==p2)==2 %Se p1=p2
                        nWalls(yy,xx,LED_R) = 0;
                    else
                        nWalls(yy,xx,LED_R) = Material_Counter(Wall_Matrix, p1, p2);
                    end
                end
            end
        end
        
        %Atenuação de propagação
        L_dB_R(:,:,LED_R) = Path_Loss(lambda_R, d_R(:,:,LED_R), k, F_dB,nWalls(:,:,LED_R), W_dB);
        
        if(Pt_R(LED_R)==0)
            [xxx,yyy,zzz]=size(L_dB_R(:,:,LED_R));
            ones_L_dB=ones(xxx,yyy,zzz);
            max_L_dB_R=max(max(L_dB_R(:,:,LED_R)));
            link_budget_LED_R(:,:,LED_R) = -max_L_dB_R*ones_L_dB;
        else
            link_budget_LED_R(:,:,LED_R) = Pt_R(LED_R)+ G_Rx_R + Ganho_tx_R(:,:,LED_R) - L_dB_R(:,:,LED_R);
            
            for yy = 1:indoor_y
                for xx = 1:indoor_x
                    if indoor(yy,xx)==1 && dx_m_R(yy,xx,LED_R)<=(raio_pixel*px2d) && Wall_Matrix(yy,xx)==0
                        indoor_link_budget_LED_R(yy,xx,LED_R)=link_budget_LED_R(yy,xx,LED_R);
                        Matrix_Coords_Raio_R(yy,xx)=1000;
                    end
                end
            end
            min_link_budget_LED_R(LED_R)=min(min(indoor_link_budget_LED_R(:,:,LED_R)));
            
            [yyy,xxx,~]=size(link_budget_LED_R(:,:,LED_R));
            for yy = 1:yyy
                for xx = 1:xxx
                    if (link_budget_LED_R(yy,xx,LED_R) < min_link_budget_LED_R(LED_R))
                        link_budget_LED_R(yy,xx,LED_R)=-max(max(L_dB_R(:,:,LED_R)));
                    end
                end
            end
            
        end
        
    end
    
    %------------ GREEN LED------------
    [LED_G_y, LED_G_x]=find(LEDs_Matrix==200);
    Coords_LED_G= [LED_G_y, LED_G_x]; %Coordenadas (y,x) de todos os LEDs verdes
    LED_G_max = size(Coords_LED_G);
    
    Matrix_Coords_Raio_G=zeros(indoor_y,indoor_x);
    dx_m_G=zeros(indoor_y,indoor_x,LED_G_max(1));
    d_G=zeros(indoor_y,indoor_x,LED_G_max(1));
    Ganho_tx_G=zeros(indoor_y,indoor_x,LED_G_max(1));
    nWalls=zeros(indoor_y,indoor_x,LED_G_max(1));
    L_dB_G=zeros(indoor_y,indoor_x,LED_G_max(1));
    link_budget_LED_G=zeros(indoor_y,indoor_x,LED_G_max(1));
    min_link_budget_LED_G=zeros(1,LED_G_max(1));
    
    for LED_G=1:LED_G_max(1)
        
        coord_LED_G=Coords_LED_G(LED_G,:); %Coordenada (y,x) de um LED verde
        p2 = coord_LED_G;
        for yy = 1:indoor_y
            for xx = 1:indoor_x
                p1=[yy,xx];
                if indoor(yy,xx)==1 %Se pertencer ao indoor
                    
                    dx_m_G(yy,xx,LED_G) = hypot(p2(2)-p1(2), p2(1)-p1(1))*px2d;
                    d_G(yy,xx,LED_G)=hypot(dx_m_G(yy,xx,LED_G), h_LED-h_PH);
                    Ganho_tx_G(yy,xx,LED_G)=GanhoTx(dx_m_G(yy,xx,LED_G),d_G(yy,xx,LED_G),Pt_G(LED_G),teta3db);
                    
                    if sum(p1==p2)==2 %Se p1=p2
                        nWalls(yy,xx,LED_G) = 0;
                    else
                        nWalls(yy,xx,LED_G) = Material_Counter(Wall_Matrix, p1, p2);
                    end
                end
            end
        end
        
        %Atenuação de propagação
        L_dB_G(:,:,LED_G) = Path_Loss(lambda_G, (d_G(:,:,LED_G)), k, F_dB,nWalls(:,:,LED_G), W_dB);
        
        %Link Budget
        if(Pt_G(LED_G)==0)
            [xxx,yyy,zzz]=size(L_dB_G(:,:,LED_G));
            ones_L_dB=ones(xxx,yyy,zzz);
            max_L_dB_G=max(max(L_dB_G(:,:,LED_G)));
            link_budget_LED_G(:,:,LED_G) = -max_L_dB_G*ones_L_dB;
        else
            link_budget_LED_G(:,:,LED_G) = Pt_G(LED_G) + G_Rx_G + Ganho_tx_G(:,:,LED_G) - L_dB_G(:,:,LED_G);
            
            for yy = 1:indoor_y
                for xx = 1:indoor_x
                    if indoor(yy,xx)==1 && dx_m_G(yy,xx,LED_G)<=(raio_pixel*px2d) && Wall_Matrix(yy,xx)==0
                        indoor_link_budget_LED_G(yy,xx,LED_G)=link_budget_LED_G(yy,xx,LED_G);
                        Matrix_Coords_Raio_G(yy,xx)=100;
                    end
                end
            end
            min_link_budget_LED_G(LED_G)=min(min(indoor_link_budget_LED_G(:,:,LED_G)));
            
            [yyy,xxx,~]=size(link_budget_LED_G(:,:,LED_G));
            for yy = 1:yyy
                for xx = 1:xxx
                    if (link_budget_LED_G(yy,xx,LED_G) < min_link_budget_LED_G(LED_G))
                        link_budget_LED_G(yy,xx,LED_G)=-max(max(L_dB_G(:,:,LED_G)));
                    end
                end
            end
            
        end
        
    end
    
    %----------- BLUE LED-----------
    [LED_B_y, LED_B_x]=find(LEDs_Matrix==300);
    Coords_LED_B= [LED_B_y, LED_B_x]; %Coordenadas (y,x) de todos os LED azuis
    LED_B_max = size(Coords_LED_B);
    
    Matrix_Coords_Raio_B=zeros(indoor_y,indoor_x);
    dx_m_B=zeros(indoor_y,indoor_x,LED_B_max(1));
    d_B=zeros(indoor_y,indoor_x,LED_B_max(1));
    Ganho_tx_B=zeros(indoor_y,indoor_x,LED_B_max(1));
    nWalls=zeros(indoor_y,indoor_x,LED_B_max(1));
    L_dB_B=zeros(indoor_y,indoor_x,LED_B_max(1));
    link_budget_LED_B=zeros(indoor_y,indoor_x,LED_B_max(1));
    min_link_budget_LED_B=zeros(1,LED_B_max(1));
    
    for LED_B=1:LED_B_max(1)
        
        coord_LED_B=Coords_LED_B(LED_B,:); %Coordenada (y,x) de um LED azul
        p2 = coord_LED_B;
        for yy = 1:indoor_y
            for xx = 1:indoor_x
                p1=[yy,xx];
                if indoor(yy,xx)==1 %Se pertencer ao indoor
                    
                    dx_m_B(yy,xx,LED_B) = hypot(p2(2)-p1(2), p2(1)-p1(1))*px2d;
                    d_B(yy,xx,LED_B)= hypot(dx_m_B(yy,xx,LED_B), h_LED-h_PH);
                    Ganho_tx_B(yy,xx,LED_B)=GanhoTx(dx_m_B(yy,xx,LED_B),d_B(yy,xx,LED_B),Pt_B(LED_B),teta3db);
                    
                    if sum(p1==p2)==2 %Se p1=p2
                        nWalls(yy,xx,LED_B) = 0;
                    else
                        nWalls(yy,xx,LED_B) = Material_Counter(Wall_Matrix, p1, p2);
                    end
                end
            end
        end
        
        %Atenuação de propagação
        L_dB_B(:,:,LED_B) = Path_Loss(lambda_B, (d_B(:,:,LED_B)), k, F_dB,nWalls(:,:,LED_B), W_dB);
        
        %Link Budget
        if(Pt_B(LED_B)==0)
            [xxx,yyy,zzz]=size(L_dB_B(:,:,LED_B));
            ones_L_dB=ones(xxx,yyy,zzz);
            max_L_dB_B=max(max(L_dB_B(:,:,LED_B)));
            link_budget_LED_B(:,:,LED_B) = -max_L_dB_B*ones_L_dB;
        else
            link_budget_LED_B(:,:,LED_B) = Pt_B(LED_B) + G_Rx_B + Ganho_tx_B(:,:,LED_B) - L_dB_B(:,:,LED_B);
            for yy = 1:indoor_y
                for xx = 1:indoor_x
                    if indoor(yy,xx)==1 && dx_m_B(yy,xx,LED_B)<=(raio_pixel*px2d) && Wall_Matrix(yy,xx)==0
                        indoor_link_budget_LED_B(yy,xx,LED_B)=link_budget_LED_B(yy,xx,LED_B);
                        Matrix_Coords_Raio_B(yy,xx)=10;
                    end
                end
            end
            min_link_budget_LED_B(LED_B)=min(min(indoor_link_budget_LED_B(:,:,LED_B)));
            
            [yyy,xxx,~]=size(link_budget_LED_B(:,:,LED_B));
            for yy = 1:yyy
                for xx = 1:xxx
                    if (link_budget_LED_B(yy,xx,LED_B) < min_link_budget_LED_B(LED_B))
                        link_budget_LED_B(yy,xx,LED_B)=-max(max(L_dB_B(:,:,LED_B)));
                    end
                end
            end
            
        end
        
    end
    
    %----------- VIOLET LED------------
    [LED_V_y, LED_V_x]=find(LEDs_Matrix==400);
    Coords_LED_V= [LED_V_y, LED_V_x]; %Coordenadas (y,x) de todos os LEDs violeta
    LED_V_max = size(Coords_LED_V);
    
    Matrix_Coords_Raio_V=zeros(indoor_y,indoor_x);
    dx_m_V=zeros(indoor_y,indoor_x,LED_V_max(1));
    d_V=zeros(indoor_y,indoor_x,LED_V_max(1));
    Ganho_tx_V=zeros(indoor_y,indoor_x,LED_V_max(1));
    nWalls=zeros(indoor_y,indoor_x,LED_V_max(1));
    L_dB_V=zeros(indoor_y,indoor_x,LED_V_max(1));
    link_budget_LED_V=zeros(indoor_y,indoor_x,LED_V_max(1));
    min_link_budget_LED_V=zeros(1,LED_V_max(1));
    
    for LED_V=1:LED_V_max(1)
        
        coord_LED_V=Coords_LED_V(LED_V,:); %Coordenada (y,x) de um LED violeta
        p2 = coord_LED_V;
        for yy = 1:indoor_y
            for xx = 1:indoor_x
                p1=[yy,xx];
                if indoor(yy,xx)==1 %Se pertencer ao indoor
                    
                    dx_m_V(yy,xx,LED_V) = hypot(p2(2)-p1(2), p2(1)-p1(1))*px2d;
                    d_V(yy,xx,LED_V)= hypot(dx_m_V(yy,xx,LED_V), h_LED-h_PH);
                    Ganho_tx_V(yy,xx,LED_V)=GanhoTx(dx_m_V(yy,xx,LED_V),d_V(yy,xx,LED_V),Pt_V(LED_V),teta3db);
                    
                    if sum(p1==p2)==2 %Se p1=p2
                        nWalls(yy,xx,LED_V) = 0;
                    else
                        nWalls(yy,xx,LED_V) = Material_Counter(Wall_Matrix, p1, p2);
                    end
                end
            end
        end
        
        %Atenuação de propagação
        L_dB_V(:,:,LED_V) = Path_Loss(lambda_V, (d_V(:,:,LED_V)), k, F_dB,nWalls(:,:,LED_V), W_dB);
        
        %Link Budget
        if(Pt_V(LED_V)==0)
            [xxx,yyy,zzz]=size(L_dB_V(:,:,LED_V));
            ones_L_dB=ones(xxx,yyy,zzz);
            max_L_dB_V=max(max(L_dB_V(:,:,LED_V)));
            link_budget_LED_V(:,:,LED_V) = -max_L_dB_V*ones_L_dB;
        else
            link_budget_LED_V(:,:,LED_V) = Pt_V(LED_V) + G_Rx_V + Ganho_tx_V(:,:,LED_V) - L_dB_V(:,:,LED_V);
            
            for yy = 1:indoor_y
                for xx = 1:indoor_x
                    if indoor(yy,xx)==1 && dx_m_V(yy,xx,LED_V)<=(raio_pixel*px2d) && Wall_Matrix(yy,xx)==0
                        indoor_link_budget_LED_V(yy,xx,LED_V)=link_budget_LED_V(yy,xx,LED_V);
                        Matrix_Coords_Raio_V(yy,xx)=1;
                    end
                end
            end
            min_link_budget_LED_V(LED_V)=min(min(indoor_link_budget_LED_V(:,:,LED_V)));
            
            [yyy,xxx,~]=size(link_budget_LED_V(:,:,LED_V));
            for yy = 1:yyy
                for xx = 1:xxx
                    if (link_budget_LED_V(yy,xx,LED_V) < min_link_budget_LED_V(LED_V))
                        link_budget_LED_V(yy,xx,LED_V)=-max(max(L_dB_V(:,:,LED_V)));
                    end
                end
            end
            
        end
        
    end
    
    %-----%Níveis de calibração-------
    
    ledsomados=Matrix_Coords_Raio_R+Matrix_Coords_Raio_G+Matrix_Coords_Raio_B+Matrix_Coords_Raio_V;
    Matrix_LED_Fprint=zeros(indoor_y,indoor_x);
    
    for fy = 1:indoor_y
        for fx = 1:indoor_x
            LED_ID=ledsomados(fy,fx);
            switch LED_ID
                case 1111
                    %Nível 15
                    Matrix_LED_Fprint(fy,fx)=15;
                case 1110
                    %Nível 14
                    Matrix_LED_Fprint(fy,fx)=14;
                case 1101
                    %Nível 13
                    Matrix_LED_Fprint(fy,fx)=13;
                case 1100
                    %Nível 12
                    Matrix_LED_Fprint(fy,fx)=12;
                case 1011
                    %Nível 11
                    Matrix_LED_Fprint(fy,fx)=11;
                case 1010
                    %%Nível 10
                    Matrix_LED_Fprint(fy,fx)=10;
                case 1001
                    %Nível 9
                    Matrix_LED_Fprint(fy,fx)=9;
                case 1000
                    %Nível 8
                    Matrix_LED_Fprint(fy,fx)=8;
                case 111
                    %Nível 7
                    Matrix_LED_Fprint(fy,fx)=7;
                case 110
                    %Nível 6
                    Matrix_LED_Fprint(fy,fx)=6;
                case 101
                    %Nível 5
                    Matrix_LED_Fprint(fy,fx)=5;
                case 100
                    %Nível 4
                    Matrix_LED_Fprint(fy,fx)=4;
                case 11
                    %Nível 3
                    Matrix_LED_Fprint(fy,fx)=3;
                case 10
                    %Nível 2
                    Matrix_LED_Fprint(fy,fx)=2;
                case 1
                    %Nível 1
                    Matrix_LED_Fprint(fy,fx)=1;
                otherwise
                    %Nível NaN
                    Matrix_LED_Fprint(fy,fx)=16;
            end
            if  (Matrix_LED_Fprint(fy,fx)==16 && Indoor_Matrix(fy,fx)==1 && Indoor_Wall_Matrix(fy,fx)==0)
                %%Nível 0
                Matrix_LED_Fprint(fy,fx)=0;
            end
        end
    end
    
    %------Soma dos link budgets dos 4 LEDs---------
    link_budget_LED_R=changem(link_budget_LED_R,-999,Inf);
    link_budget_LED_G=changem(link_budget_LED_G,-999,Inf);
    link_budget_LED_B=changem(link_budget_LED_B,-999,Inf);
    link_budget_LED_V=changem(link_budget_LED_V,-999,Inf);
    
    link_budget_LED_R=10.^(link_budget_LED_R/10)/1000;
    link_budget_LED_G=10.^(link_budget_LED_G/10)/1000;
    link_budget_LED_B=10.^(link_budget_LED_B/10)/1000;
    link_budget_LED_V=10.^(link_budget_LED_V/10)/1000;
    
    link_budget_final=sum(link_budget_LED_R,3)+ sum(link_budget_LED_G,3)+sum(link_budget_LED_B,3)+sum(link_budget_LED_V,3);
    link_budget_final= 10*log10(link_budget_final*1000);
    
    %% --- GERAÇÃO DE GRÁFICOS ---
    if CC_FLAG==1
        %--------------Área de transmissão de cada LED---------------
        figure('name','Área de transmissão de cada LED')
        
        for red=1:LED_R_max(1)
            F_Pt_R=[Pt_R(2), Pt_R(1)];
            if(F_Pt_R(red))~=0
                h_r=Circle(LED_R_x(red,1), LED_R_y(red,1),raio_pixel,1);
                hold on;
            end
        end
        
        for green=1:LED_G_max(1)
            if(Pt_G(green))~=0
                h_g=Circle(LED_G_x(green,1), LED_R_y(green,1),raio_pixel,2);
                hold on;
            end
        end
        
        for blue=1:LED_B_max(1)
            F_Pt_B=[Pt_B(3), Pt_B(4), Pt_B(1), Pt_B(2)];
            if(F_Pt_B(blue))~=0
                h_b=Circle(LED_B_x(blue,1), LED_B_y(blue,1),raio_pixel,3);
                hold on;
            end
        end
        
        for violet=1:LED_V_max(1)
            if(Pt_V(violet))~=0
                h_v=Circle(LED_V_x(violet,1), LED_V_y(violet,1),raio_pixel,4);
                hold on;
            end
        end
        
        set(gca,'xdir','reverse','ydir','reverse') % This command will rotate the plot by 180 degree
        im2 = image(imread('piso_3_LEDs_fprints.bmp'));
        im2.AlphaData = 0.5;
        title(sprintf('Área de Transmissão de cada LED\n numa Sala %.2f x %.2f cm\n', dim_sala, dim_sala))
        axis off;
        hold off;
        
        %-----------------Exclusão de valores------------------
        for fy = 1:indoor_y
            for fx = 1:indoor_x
                if  round(link_budget_final(fy,fx))==-244
                    link_budget_final(fy,fx)=-2.382552874348818e+02;
                end
                if  round(link_budget_final(fy,fx))==-179
                    link_budget_final(fy,fx)=-1.808403807516161e+02;
                end
            end
        end
        
        %--------------Mapra de cores da Cobertura Prevista em DL------------------
        figure('name','Downlink - Mapa de Cores')
        imagesc(link_budget_final);
        title('Mapa de Cores da Potência Recebida (dBm)')
        colormap(jet);
        %colormap(colorcube);
        colorbar;
        m=max(max(link_budget_final));
        caxis([-204 m])
        axis off;
        
        %-------Função densidade de probabilidade (PDF)-------
        
        figure('name','PDF LEDs DL');
        histogram(link_budget_final,'Normalization','pdf','BinWidth',1);
        %xlim([-239 -178])
        yticklabels(yticks*100)
        title('Densidade de Probabilidade (PDF) em Downlink')
        xlabel('Potência Recebida [dBm]')
        ylabel('Frequência [%]')
        
        %-------Função de Distribuição Cumulativa (CDF)-------
        
        figure('name','CDF LEDs DL');
        histogram(link_budget_final,'Normalization','cdf','BinWidth',1);
        %xlim([-239 -178])
        ylim([0 1.05])
        yticklabels(yticks*100)
        title('Distribuição Cumulativa (CDF) em Downlink')
        xlabel('Potência Recebida [dBm]')
        ylabel('Probabilidade [%]')
        
        %-------Mapa de cores dos Níveis de Calibração-------
        figure;
        imagesc(Matrix_LED_Fprint);
        colormap(colorcube(16));
        colorbar('Ticks',[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],...
            'TickLabels',{'0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'})
        axis off;
        title('Mapa de Cores de Níveis de Calibração')       
    else
    end
    
    %--------Sinal Transmitido--------
    length_SR=length(SR);
    
    %MODULATION <----------------------------------------------------------
    %SR = tfm_modulation(SR,mod_select);
    %SG = tfm_modulation(SG,mod_select);
    %SB = tfm_modulation(SB,mod_select);
    %SV = tfm_modulation(SV,mod_select);
    
    %BIT TIME ARRAY FOR X AXIS PLOTS, AND SAMPLES PER BIT
    bit_time_x_corrigido = [0:DeltaT:(DeltaT*length(SR))-DeltaT];
    if capacitive_select
        bit_time_x = [0:(DeltaT/capacitive_samples):(DeltaT*length(SR))-(DeltaT/capacitive_samples)];
    else
        bit_time_x = bit_time_x_corrigido;
        capacitive_samples = 1;
    end
    
    %NOISE <---------------------------------------------------------------
    %[SR_ruido_bits,SR_ruido_sinal] = tfm_ruido(SR,ruido_select,1);
    %[SG_ruido_bits,SG_ruido_sinal] = tfm_ruido(SG,ruido_select,0);
    %[SB_ruido_bits,SB_ruido_sinal] = tfm_ruido(SB,ruido_select,0);
    %[SV_ruido_bits,SV_ruido_sinal] = tfm_ruido(SV,ruido_select,0);
    
    %CAPACITIVE BEHAVIOR <-------------------------------------------------
    if capacitive_select
        %[SR_capacitive] = tfm_capacitive(SR,capacitive_howmuch,1,capacitive_samples);
        %[SG_capacitive] = tfm_capacitive(SG,capacitive_howmuch,0,capacitive_samples);
        %[SB_capacitive] = tfm_capacitive(SB,capacitive_howmuch,0,capacitive_samples);
        %[SV_capacitive] = tfm_capacitive(SV,capacitive_howmuch,0,capacitive_samples);
%         [SR_capacitive,SR_plot] = tfm_capacitive_v2(SR,capacitive_howmuch,0,capacitive_samples);
%         [SG_capacitive,SG_plot] = tfm_capacitive_v2(SG,capacitive_howmuch,0,capacitive_samples);
%         [SB_capacitive,SB_plot] = tfm_capacitive_v2(SB,capacitive_howmuch,0,capacitive_samples);
%         [SV_capacitive,SV_plot] = tfm_capacitive_v2(SV,capacitive_howmuch,0,capacitive_samples);
        [SR_capacitive,SR_plot] = tfm_capacitive_v3(SR,capacitive_howmuch,0,capacitive_samples);
        [SG_capacitive,SG_plot] = tfm_capacitive_v3(SG,capacitive_howmuch,0,capacitive_samples);
        [SB_capacitive,SB_plot] = tfm_capacitive_v3(SB,capacitive_howmuch,0,capacitive_samples);
        [SV_capacitive,SV_plot] = tfm_capacitive_v3(SV,capacitive_howmuch,0,capacitive_samples);
    else
        %[SR_capacitive,SR_plot] = tfm_capacitive_v3(SR,99,0,1);
        %[SG_capacitive,SG_plot] = tfm_capacitive_v3(SG,99,0,1);
        %[SB_capacitive,SB_plot] = tfm_capacitive_v3(SB,99,0,1);
        %[SV_capacitive,SV_plot] = tfm_capacitive_v3(SV,99,0,1);
        SR_capacitive = SR(1,:);
        SG_capacitive = SG(1,:);
        SB_capacitive = SB(1,:);
        SV_capacitive = SV(1,:);
        SR_plot = SR(1,:)-6;
        SG_plot = SG(1,:)-6.5;
        SB_plot = SB(1,:)-7;
        SV_plot = SV(1,:)-7.5;
    end
    
    %O código continua a partir daqui...
    size_SR=size(SR);
    SR_Y=size_SR(1);
    SR_X=size_SR(2);
    
    for sr_y=1:SR_Y
        for sr_x=1:SR_X
           
            if(SR(sr_y,sr_x)==0)
                SR(sr_y,sr_x)=7;
            else
                SR(sr_y,sr_x)=7.2;
            end
            if(SG(sr_y,sr_x)==0)
                SG(sr_y,sr_x)=7.5;
            else
                SG(sr_y,sr_x)=7.7;
            end
            if(SB(sr_y,sr_x)==0)
                SB(sr_y,sr_x)=8;
            else
                SB(sr_y,sr_x)=8.2;
            end
            if(SV(sr_y,sr_x)==0)
                SV(sr_y,sr_x)=8.5;
            else
                SV(sr_y,sr_x)=8.7;
            end
            
            if(P_R(sr_y,sr_x)==0)
                P_r(sr_y,sr_x)=7;
            else
                P_r(sr_y,sr_x)=7.2;
            end
            if(P_G(sr_y,sr_x)==0)
                P_g(sr_y,sr_x)=7.5;
            else
                P_g(sr_y,sr_x)=7.7;
            end
            if(P_B(sr_y,sr_x)==0)
                P_b(sr_y,sr_x)=8;
            else
                P_b(sr_y,sr_x)=8.2;
            end
            if(P_V(sr_y,sr_x)==0)
                P_v(sr_y,sr_x)=8.5;
            else
                P_v(sr_y,sr_x)=8.7;
            end
        end
    end
    
    x_S_RGBV=0:1:length_SR-1;
    xx_S_RGBV=x_S_RGBV*DeltaT;
    
    %---CM---
    length_CMSR=length(CM_SR);
    if length_CMSR~=64
        %warning('Rodrigues: O Sinal CM Transmitido tem de ter 64 bits!')
    end
    size_CMSR=size(CM_SR);
    CMSR_Y=size_CMSR(1);
    CMSR_X=size_CMSR(2);
    
    for sr_y=1:CMSR_Y
        for sr_x=1:CMSR_X
            
            if(CM_SR(sr_y,sr_x)==0)
                CM_SR(sr_y,sr_x)=7;
            else
                CM_SR(sr_y,sr_x)=7.2;
            end
            if(CM_SG(sr_y,sr_x)==0)
                CM_SG(sr_y,sr_x)=7.5;
            else
                CM_SG(sr_y,sr_x)=7.7;
            end
            if(CM_SB(sr_y,sr_x)==0)
                CM_SB(sr_y,sr_x)=8;
            else
                CM_SB(sr_y,sr_x)=8.2;
            end
            if(CM_SV(sr_y,sr_x)==0)
                CM_SV(sr_y,sr_x)=8.5;
            else
                CM_SV(sr_y,sr_x)=8.7;
            end
        end
    end
    
    CM_x_S_RGBV=0:1:length_CMSR-1;
    CM_xx_S_RGBV=CM_x_S_RGBV*DeltaT;
    
    temp_y_stairs=zeros(1,16);
    count_1=1;count_2=1;count_3=1;count_4=1;count_5=1;count_6=1;count_7=1;count_8=1;count_9=1;count_10=1;count_11=1;count_12=1;count_13=1;count_14=1;count_15=1;count_16=1;
    
    for fy = 1:indoor_y
        for fx = 1:indoor_x
            LED_ID_x=Matrix_LED_Fprint(fy,fx);
            switch LED_ID_x
                case 15
                    %Nível 15
                    temp_y_stairs_15(count_16)=link_budget_final(fy,fx);
                    temp_y_stairs(1,16)=min(temp_y_stairs_15,[],2);
                    count_16=count_16+1;
                case 14
                    %Nível 14
                    temp_y_stairs_14(count_15)=link_budget_final(fy,fx);
                    temp_y_stairs(1,15)=min(temp_y_stairs_14,[],2);
                    count_15=count_15+1;
                case 13
                    %Nível 13
                    temp_y_stairs_13(count_14)=link_budget_final(fy,fx);
                    temp_y_stairs(1,14)=min(temp_y_stairs_13,[],2);
                    count_14=count_14+1;
                case 12
                    %Nível 12
                    temp_y_stairs_12(count_13)=link_budget_final(fy,fx);
                    temp_y_stairs(1,13)=min(temp_y_stairs_12,[],2);
                    count_13=count_13+1;
                case 11
                    %Nível 11
                    temp_y_stairs_11(count_12)=link_budget_final(fy,fx);
                    temp_y_stairs(1,12)=min(temp_y_stairs_11,[],2);
                    count_12=count_12+1;
                case 10
                    %Nível 10
                    temp_y_stairs_10(count_11)=link_budget_final(fy,fx);
                    temp_y_stairs(1,11)=min(temp_y_stairs_10,[],2);
                    count_11=count_11+1;
                case 9
                    %Nível 9
                    temp_y_stairs_9(count_10)=link_budget_final(fy,fx);
                    temp_y_stairs(1,10)=min(temp_y_stairs_9,[],2);
                    count_10=count_10+1;
                case 8
                    %Nível 8
                    temp_y_stairs_8(count_9)=link_budget_final(fy,fx);
                    temp_y_stairs(1,9)=min(temp_y_stairs_8,[],2);
                    count_9=count_9+1;
                case 7
                    %Nível 7
                    temp_y_stairs_7(count_8)=link_budget_final(fy,fx);
                    temp_y_stairs(1,8)=min(temp_y_stairs_7,[],2);
                    count_8=count_8+1;
                case 6
                    %%Nível 6
                    temp_y_stairs_6(count_7)=link_budget_final(fy,fx);
                    temp_y_stairs(1,7)=min(temp_y_stairs_6,[],2);
                    count_7=count_7+1;
                case 5
                    %Nível 5
                    temp_y_stairs_5(count_6)=link_budget_final(fy,fx);
                    temp_y_stairs(1,6)=min(temp_y_stairs_5,[],2);
                    count_6=count_6+1;
                case 4
                    %Nível 4
                    temp_y_stairs_4(count_5)=link_budget_final(fy,fx);
                    temp_y_stairs(1,5)=min(temp_y_stairs_4,[],2);
                    count_5=count_5+1;
                case 3
                    %Nível 3
                    temp_y_stairs_3(count_4)=link_budget_final(fy,fx);
                    temp_y_stairs(1,4)=min(temp_y_stairs_3,[],2);
                    count_4=count_4+1;
                case 2
                    %Nível 2
                    temp_y_stairs_2(count_3)=link_budget_final(fy,fx);
                    temp_y_stairs(1,3)=min(temp_y_stairs_2,[],2);
                    count_3=count_3+1;
                case 1
                    %Nível 1
                    temp_y_stairs_1(count_2)=link_budget_final(fy,fx);
                    temp_y_stairs(1,2)=min(temp_y_stairs_1,[],2);
                    count_2=count_2+1;
                case 0
                    %Nível 0
                    temp_y_stairs_0(count_1)=link_budget_final(fy,fx);
                    temp_y_stairs(1,1)=max(temp_y_stairs_0,[],2);
                    count_1=count_1+1;
            end
        end
    end
    
    count_t2ys=1;
    for u=1:length(temp_y_stairs)
        str_u=num2str(u);
        newcount=sprintf('count_%s' ,str_u);
        if (temp_y_stairs(u)~=0) && (eval(newcount)~=1)
            temp2_y_stairs(count_t2ys)=temp_y_stairs(u);
            count_t2ys=count_t2ys+1;
        end
    end
    
    y_stairs=(10.^(unique(temp2_y_stairs)/10))/1000;
    
    %------------Normalização dos valores do Sinal Recebido (Prx)----------------
    yy_stairs = (y_stairs - min(y_stairs)) / ( max(y_stairs) - min(y_stairs) );
    
    x_stairs=0:length(yy_stairs)-1;
    xx_stairs=x_stairs*DeltaT;
    
    yyy_stairs=[yy_stairs 1];
    xxx_stairs=[xx_stairs length(yy_stairs)*DeltaT];
    
    if CC_FLAG==1
        figure('name','Sinal Recebido')
        stairs(xxx_stairs,yyy_stairs,'LineWidth',2);
        if (G_rx_r~=0)
            title('Curva de Calibração STD com Ganho (Teórico)')
        else
            title('Curva de Calibração STD sem Ganho (Teórico)')
        end
        xlabel('Tempo [ms]')
        ylabel('Intensidade Normalizada')
        xlim([0 1.28])
        ylim([0 1.05])
    end
    
    CR=yy_stairs(9);%GR=585.9984e-003;
    CG=yy_stairs(5);%GG=278.8719e-003;
    CB=yy_stairs(3);%GB=93.6494e-003;
    CV=yy_stairs(2);%GV=41.3593e-003;
    
    %COEFICIENTES
    %coeficient.R = 0.543676621;
    %coeficient.G = 0.292608684;
    %coeficient.B = 0.123396879;
    %coeficient.V = 0.040317816;
    coeficient.R = CR;
    coeficient.G = CG;
    coeficient.B = CB;
    coeficient.V = CV;
    
    %PLOT CAPACITIVE CURVES AND MUX <---------------------------------
    figure('name','Simulation Result');
    %SR_capacitive = SR_capacitive*coeficient.R;
    %SG_capacitive = SG_capacitive*coeficient.G;
    %SB_capacitive = SB_capacitive*coeficient.B;
    %SV_capacitive = SV_capacitive*coeficient.V;
    subplot(2,1,1)
    emitted_R = SR_plot(1,:);
    emitted_G = SG_plot(1,:);
    emitted_B = SB_plot(1,:);
    emitted_V = SV_plot(1,:);
    if capacitive_select
          stairs(bit_time_x,emitted_R+9,'r','LineWidth',1.5); axis tight; hold on;
          stairs(bit_time_x,emitted_G+6,'g','LineWidth',1.5); axis tight; hold on;
          stairs(bit_time_x,emitted_B+3,'b','LineWidth',1.5); axis tight; hold on;
          stairs(bit_time_x,emitted_V+0,'m','LineWidth',1.5); axis tight; hold on;
          ylim([min(SV_capacitive(1,:))-0.5 max(SR_plot(1,:))+9+0.5+2])
    else
        stairs(bit_time_x,SR_capacitive(1,:)+9,'r','LineWidth',1.5); axis tight; hold on;
        stairs(bit_time_x,SG_capacitive(1,:)+6,'g','LineWidth',1.5); axis tight; hold on;
        stairs(bit_time_x,SB_capacitive(1,:)+3,'b','LineWidth',1.5); axis tight; hold on;
        stairs(bit_time_x,SV_capacitive(1,:)+0,'m','LineWidth',1.5); axis tight; hold on;
        ylim([min(SV_capacitive(1,:))-0.5 max(SR_capacitive(1,:))+9+0.5+2])
    end
    yticks([0:3:9])
    yticklabels({'V','B','G','R'})
    xlabel('Time [ms]')
    title('Emitted Signals (LEDs)')
    if strcmp(mod_select,'OOK')
        multiplier = 1;
    elseif strcmp(mod_select,'Manchester')
        multiplier = 2;
    end
    if length(input_bits_R1) >= 62
        if capacitive_select
            xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
        else
            xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
        end
    end
    
    subplot(2,1,2)
    %somatorio = (SR_capacitive(1,:)*CR+SG_capacitive(1,:)*CG+SB_capacitive(1,:)*CB+SV_capacitive(1,:)*CV);
    %somatorio = (SR_capacitive(1,:)+SG_capacitive(1,:)+SB_capacitive(1,:)+SV_capacitive(1,:));
    somatorio = (SR_capacitive(1,:)*coeficient.R+SG_capacitive(1,:)*coeficient.G+SB_capacitive(1,:)*coeficient.B+SV_capacitive(1,:)*coeficient.V);
    somatorio = somatorio*15;
    if capacitive_select
        plot(bit_time_x,somatorio); axis tight; hold on;
    else
        stairs(bit_time_x,somatorio); axis tight; hold on;
    end
    mux_corrigido = tfm_mux_correction(somatorio,capacitive_samples);
    stairs(bit_time_x_corrigido,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
    yticks(linspace(0,15,16))
    yticklabels({'0000','0001','0010',' 0011','0100','0101','0110','0111',...
        '1000','1001','1010','1011','1100','1101','1110','1111'})
    ylim([0 15.5+2])
    if length(input_bits_R1) >= 62
        if capacitive_select
            xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
        else
            xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
            xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
        end
    end
    set(gca, 'YGrid', 'on', 'XGrid', 'off')
    xlabel('Time [ms]')
    title('Received Signal (Photodiode)')
    %set(gcf, 'Position',  [100, 100, 800, 600])
    set(gcf, 'Position',  [100, 100, 1600, 600])
    %lol = 1;
    
%     %<--------------------------DELETE LATER!
%     if capacitive_select %Tem de haver capacitive_select = 1! e Scenario 1!
%         figure('name','Extra - Compare')
%         plot(bit_time_x,somatorio,'LineWidth',1.5); axis tight; hold on;
%         %raw_excel = readmatrix('C:\Users\joaom\Dropbox\TFM\Scenarios\Best Measurements V5 (round)\Scenario1.xls','Sheet',mod_select);
%         if strcmp(mod_select,'OOK')
%             raw_excel = readmatrix('C:\Users\joaom\Dropbox\TFM\Scenarios\Best Measurements\Scenario1.xls','Sheet','OOK');
%             Time_EXCEL = raw_excel(:,1)'*1000;
%             Time_EXCEL = Time_EXCEL(951:2012);
%             MUX_EXCEL = raw_excel(:,6)';
%             MUX_EXCEL = MUX_EXCEL(951:2012);
%             bad_idxs = [17 50 83 116 149 182 215 216 249 282 315 348 381 382 415 448 481 514 547 548 581 614 631 664 697 714 747 796 797 830 863 880 913 946 963 996 1061 1062];
%         else
%             if strcmp(mod_select,'Manchester')
%                 raw_excel = readmatrix('C:\Users\joaom\Dropbox\TFM\Scenarios\Best Measurements\Scenario1.xls','Sheet','MAN');
%                 Time_EXCEL = raw_excel(:,1)'*1000;
%                 Time_EXCEL = Time_EXCEL(951:3075);
%                 MUX_EXCEL = raw_excel(:,6)';
%                 MUX_EXCEL = MUX_EXCEL(951:3075);
%                 bad_idxs = [17 50 83 116 149 182 199 216 249 266 299 332 365 382 415 432 465 498 531 548];
%                 bad_idxs = [bad_idxs 581 598 631 664 697 714 747 780 797 830 863 880 913 946 963 996 1029 1046];
%                 bad_idxs = [bad_idxs 1079 1112 1129 1162 1195 1212 1245 1262 1311 1328 1361 1378 1411 1444 1461];
%                 bad_idxs = [bad_idxs 1494 1527 1544 1577 1594 1627 1676 1693 1710 1743 1760 1809 1826 1859 1876];
%                 bad_idxs = [bad_idxs 1909 1926 1959 1992 2025 2042 2075 2092 2125];
%             else
%                 error('X');
%             end
%         end
%         %Time_EXCEL(bad_idxs) = [];
%         MUX_EXCEL(bad_idxs) = [];
%         Time_EXCEL = Time_EXCEL-Time_EXCEL(1);
%         MUX_EXCEL = MUX_EXCEL./max(MUX_EXCEL);
%         MUX_EXCEL = MUX_EXCEL*15;
%         Time_EXCEL = Time_EXCEL(1:length(MUX_EXCEL));
%         
%         plot(Time_EXCEL,MUX_EXCEL,'LineWidth',1.5); axis tight; hold on;
%         yticks(linspace(0,15,16))
%         yticklabels({'0000','0001','0010',' 0011','0100','0101','0110','0111',...
%             '1000','1001','1010','1011','1100','1101','1110','1111'})
%         ylim([0 15.5+2])
%         set(gca, 'YGrid', 'on', 'XGrid', 'off')
%         xlabel('Time [ms]')
%         legend('Simulated','Measured','Location','northwest','NumColumns',2)
%         set(gcf, 'Position',  [100, 100, 1200, 600/2])
%     end  
%     
%     figure('name','Extra - Encoding')
%     if capacitive_select
%         stairs(bit_time_x,SR_plot(1,:)+9,'r','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,SG_plot(1,:)+6,'g','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,SB_plot(1,:)+3,'b','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,SV_plot(1,:)+0,'m','LineWidth',1.5); axis tight; hold on;
%         ylim([min(SV_capacitive(1,:))-0.5 max(SR_plot(1,:))+9+0.5+2])
%         set(gcf, 'Position',  [100, 100, 800*2, 400])
%     else
%         stairs(bit_time_x,SR_capacitive(1,:)+9,'r','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,SG_capacitive(1,:)+6,'g','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,SB_capacitive(1,:)+3,'b','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,SV_capacitive(1,:)+0,'m','LineWidth',1.5); axis tight; hold on;
%         ylim([min(SV_capacitive(1,:))-0.5 max(SR_capacitive(1,:))+9+0.5+2])
%         set(gcf, 'Position',  [100, 100, 800*2, 400])
%     end
%     yticks([0:3:9])
%     yticklabels({'V','B','G','R'})
%     xlabel('Time [ms]')
%     title('Emitted Signals (LEDs)')
%     if strcmp(mod_select,'OOK')
%         multiplier = 1;
%     elseif strcmp(mod_select,'Manchester')
%         multiplier = 2;
%     end
%     if length(input_bits_R1) >= 62
%         if capacitive_select
%             xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
%         else
%             xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
%         end
%     end
%     set(gcf, 'Position',  [100, 100, 800*2, 400])
%     %set(gcf, 'Position',  [488, 342, 560+250, 420])
%     
%     figure('name','Extra - Decoding')
%     if capacitive_select
%         plot(bit_time_x,somatorio,'LineWidth',1.5); axis tight; hold on;
%     else
%         stairs(bit_time_x,somatorio,'LineWidth',1.5); axis tight; hold on;
%     end
%     mux_corrigido = tfm_mux_correction(somatorio,capacitive_samples);
%     %stairs(bit_time_x_corrigido,mux_corrigido,'LineWidth',1.5); axis tight; hold on;
%     yticks(linspace(0,15,16))
%     yticklabels({'0000','0001','0010',' 0011','0100','0101','0110','0111',...
%         '1000','1001','1010','1011','1100','1101','1110','1111'})
%     ylim([0 15.5+2])
%     if length(input_bits_R1) >= 62
%         if capacitive_select
%             xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
%         else
%             xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
%             xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
%         end
%     end
%     set(gca, 'YGrid', 'on', 'XGrid', 'off')
%     xlabel('Time [ms]')
%     title('Received Signal (Photodiode)')
%     %set(gcf, 'Position',  [100, 100, 800, 600])
%     %set(gcf, 'Position',  [488, 342, 560+250, 420])
%     set(gcf, 'Position',  [100, 100, 800*2, 400])
%     %488.0000e+000   342.0000e+000   560.0000e+000   420.0000e+000
%     %Extra stuff ends here. Don't delete past this!<--------------
    
    %DECODE BITS FROM MUX
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
    if strcmp(mod_select,'Manchester')
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
    end
    if strcmp(mod_select,'OOK')
        received.tudo = [received.R; received.G; received.B; received.V; mux_corrigido]; %For debugging purposes
    end
    disp('------------------ Decoded Simulated Transmission ------------------')
    if length(input_bits_R1) >= 64
        tfm_navdata(received);
    else
        warning(['Navigation data decoding not currently possible, as tfm_data is made for data frames of 64 bits and the currently used data frame has '...
            ,num2str(length(input_bits_R1)),' bits.']);
    end
    
    if BER_FLAG
        disp('------------------------------- BER ---------------------------------')
        bits_errados.R = sum(xor(received.R,sent.R(1,:)));
        bits_errados.G = sum(xor(received.G,sent.G(1,:)));
        bits_errados.B = sum(xor(received.B,sent.B(1,:)));
        bits_errados.V = sum(xor(received.V,sent.V(1,:)));
        bits_errados.total = bits_errados.R+bits_errados.G+bits_errados.B+bits_errados.V;
        numero_bits_total = length(sent.R)+length(sent.G)+length(sent.B)+length(sent.V);
        BER = (bits_errados.total/numero_bits_total);
        disp([num2str(bits_errados.total),' wrong bit(s) (BER = ',num2str(BER*100),'%)']);
        disp([num2str(bits_errados.R),' of which came from the red emitter.']);
        disp([num2str(bits_errados.G),' of which came from the green emitter.']);
        disp([num2str(bits_errados.B),' of which came from the blue emitter.']);
        disp([num2str(bits_errados.V),' of which came from the violet emitter.']);
    end
    
    %PARITY
    if parity_select
        if capacitive_select
%             Rp = xor(xor(SV_plot(1,:),SR_plot(1,:)),SB_plot(1,:));
%             Gp = xor(xor(SV_plot(1,:),SR_plot(1,:)),SG_plot(1,:));
%             Bp = xor(xor(SV_plot(1,:),SG_plot(1,:)),SB_plot(1,:));
%             Vp = zeros(1,length(Rp));
            Rp = xor(xor(sent.V(1,:),sent.R(1,:)),sent.B(1,:));
            Gp = xor(xor(sent.V(1,:),sent.R(1,:)),sent.G(1,:));
            Bp = xor(xor(sent.V(1,:),sent.G(1,:)),sent.B(1,:));
            Vp = zeros(1,length(Rp));
        else
            Rp = xor(xor(SV_capacitive(1,:),SR_capacitive(1,:)),SB_capacitive(1,:));
            Gp = xor(xor(SV_capacitive(1,:),SR_capacitive(1,:)),SG_capacitive(1,:));
            Bp = xor(xor(SV_capacitive(1,:),SG_capacitive(1,:)),SB_capacitive(1,:));
            Vp = zeros(1,length(Rp));
        end
        
        figure('name','Simulated Parity Signal')
        %parity_signal = Rp*coeficient.R+Gp*coeficient.G+Bp*coeficient.B+Vp*coeficient.V;
        %parity_signal = Rp*0.5+Gp*0.25+Bp*0.125+Vp*(0.125/2);
        Rp = tfm_modulation(Rp,mod_select,0);
        Gp = tfm_modulation(Gp,mod_select,0);
        Bp = tfm_modulation(Bp,mod_select,0);
        Vp = tfm_modulation(Vp,mod_select,0);
        if strcmp(mod_select,'OOK')
            Rp = Rp';
            Gp = Gp';
            Bp = Bp';
            Vp = Vp';
        else
            %if strcmp(mod_select,'Manchester')
            %else
                %error('X');
            %end
        end
        [Rp,SR_plot] = tfm_capacitive_v3(Rp,capacitive_howmuch,0,capacitive_samples);
        [Gp,SG_plot] = tfm_capacitive_v3(Gp,capacitive_howmuch,0,capacitive_samples);
        [Bp,SB_plot] = tfm_capacitive_v3(Bp,capacitive_howmuch,0,capacitive_samples);
        [Vp,SV_plot] = tfm_capacitive_v3(Vp,capacitive_howmuch,0,capacitive_samples);
        parity_signal = Rp*CR+Gp*CG+Bp*CB+Vp*CV;
        parity_signal = parity_signal*15;
        if capacitive_select
            plot(bit_time_x(1:end),parity_signal); axis tight; hold on;
            parity_corrigido = tfm_mux_correction(parity_signal,capacitive_samples);
        else
            stairs(bit_time_x,parity_signal); axis tight; hold on;
            parity_corrigido = tfm_mux_correction(parity_signal,1);
        end
        stairs(bit_time_x_corrigido(1:end),parity_corrigido,'LineWidth',1.5); axis tight; hold on;
        ylim([-1 15+1.5])
        xlabel('Time [ms]')
        ylabel('Parity levels')
        yticks([0:2:14])
        yticklabels({'p_0','p_2','p_4','p_6','p_8','p_1_0','p_1_2','p_1_4'})
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        if strcmp(mod_select,'OOK')
            multiplier = 1;
        elseif strcmp(mod_select,'Manchester')
            multiplier = 2;
        end
        xline(bit_time_x_corrigido(1)*multiplier,'--',{'Sync'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(5+1)*multiplier,'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(37+1)*multiplier,'--',{'x'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(41+1)*multiplier,'--',{'y'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(45+1)*multiplier,'--',{'z'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(49+1)*multiplier,'--',{'Pin_1'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(53+1)*multiplier,'--',{'Pin_2'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(57+1)*multiplier,'--',{'Angle'},'LabelOrientation','Horizontal');
        xline(bit_time_x_corrigido(61+1)*multiplier,'--',{'PL'},'LabelOrientation','Horizontal');
        set(gcf, 'Position',  [100, 100, 800, 300])
        
        figure('name','Simulation Result (with Parity)')
        subplot(2,1,1)
%         stairs(bit_time_x,Rp+9,'r','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,Gp+6,'g','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,Bp+3,'b','LineWidth',1.5); axis tight; hold on;
%         stairs(bit_time_x,Vp+0,'m','LineWidth',1.5); axis tight; hold on;
        if capacitive_select
%             stairs(bit_time_x,SR_plot(1,:)+9,'r','LineWidth',1.5); axis tight; hold on;
%             stairs(bit_time_x,SG_plot(1,:)+6,'g','LineWidth',1.5); axis tight; hold on;
%             stairs(bit_time_x,SB_plot(1,:)+3,'b','LineWidth',1.5); axis tight; hold on;
%             stairs(bit_time_x,SV_plot(1,:)+0,'m','LineWidth',1.5); axis tight; hold on;
            stairs(bit_time_x,emitted_R+9,'r','LineWidth',1.5); axis tight; hold on;
            stairs(bit_time_x,emitted_G+6,'g','LineWidth',1.5); axis tight; hold on;
            stairs(bit_time_x,emitted_B+3,'b','LineWidth',1.5); axis tight; hold on;
            stairs(bit_time_x,emitted_V+0,'m','LineWidth',1.5); axis tight; hold on;
            ylim([min(SV_capacitive(1,:))-0.5 max(SR_plot(1,:))+9+0.5+2])
        else
            stairs(bit_time_x,SR_capacitive(1,:)+9,'r','LineWidth',1.5); axis tight; hold on;
            stairs(bit_time_x,SG_capacitive(1,:)+6,'g','LineWidth',1.5); axis tight; hold on;
            stairs(bit_time_x,SB_capacitive(1,:)+3,'b','LineWidth',1.5); axis tight; hold on;
            stairs(bit_time_x,SV_capacitive(1,:)+0,'m','LineWidth',1.5); axis tight; hold on;
            ylim([min(SV_capacitive(1,:))-0.5 max(SR_capacitive(1,:))+9+0.5+2])
        end
        ylim([min(Vp)-0.5 max(Rp)+9+0.5+2])
        yticks([0:3:9])
        yticklabels({'V','B','G','R'})
        xlabel('Time [ms]')
        title('Emitted Signals (LEDs)')
        if length(input_bits_R1) >= 62
            if capacitive_select
                xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
            else
                xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
            end
        end
        hold off;
                 
        subplot(2,1,2)
        [received,decoded4plot] = tfm_parity_decoder (parity_corrigido,mux_corrigido);
        if capacitive_select
            plot(bit_time_x,somatorio); axis tight; hold on;
            stairs(bit_time_x_corrigido,decoded4plot,'LineWidth',1.5); axis tight; hold on;
        else
            stairs(bit_time_x,somatorio); axis tight; hold on;
            stairs(bit_time_x_corrigido,decoded4plot,'LineWidth',1.5); axis tight; hold on;
        end
        yticks(linspace(0,15,16))
        yticklabels({'0000','0001','0010',' 0011','0100','0101','0110','0111',...
            '1000','1001','1010','1011','1100','1101','1110','1111'})
        ylim([0 15.5+2])
        if length(input_bits_R1) >= 62
            if capacitive_select
                xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
            else
                xline(0,'--',{'Synch'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((5)*multiplier+1),'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((37)*multiplier+1),'--',{'x'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((41)*multiplier+1),'--',{'y'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((45)*multiplier+1),'--',{'z'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((49)*multiplier+1),'--',{'Pin_1'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((53)*multiplier+1),'--',{'Pin_2'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((57)*multiplier+1),'--',{'Angle'},'LabelOrientation','Horizontal');
                xline(bit_time_x_corrigido((61)*multiplier+1),'--',{'PL'},'LabelOrientation','Horizontal');
            end
        end
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        xlabel('Time [ms]')
        title('Received Signal (Photodiode)')
        %set(gcf, 'Position',  [100, 100, 800, 600])
        set(gcf, 'Position',  [100, 100, 1600, 600])
        
        %DECODE BITS FROM MUX
        received.R = zeros(1,length(decoded4plot));
        received.G = zeros(1,length(decoded4plot));
        received.B = zeros(1,length(decoded4plot));
        received.V = zeros(1,length(decoded4plot));
        for i = 1:length(decoded4plot)
            actual = decoded4plot(i);
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
        if strcmp(mod_select,'Manchester')
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
        end
        
        disp('------------ Decoded Simulated Transmission (with Parity) -----------')
        if length(input_bits_R1) >= 64
            tfm_navdata(received);
        else
            warning(['Navigation data decoding not currently possible, as tfm_data is made for data frames of 64 bits and the currently used data frame has '...
                ,num2str(length(input_bits_R1)),' bits.']);
        end
        
        if BER_FLAG
            disp('------------------------------- BER ---------------------------------')
            bits_errados.R = sum(xor(received.R,sent.R(1,:)));
            bits_errados.G = sum(xor(received.G,sent.G(1,:)));
            bits_errados.B = sum(xor(received.B,sent.B(1,:)));
            bits_errados.V = sum(xor(received.V,sent.V(1,:)));
            bits_errados.total = bits_errados.R+bits_errados.G+bits_errados.B+bits_errados.V;
            numero_bits_total = length(sent.R)+length(sent.G)+length(sent.B)+length(sent.V);
            BER = (bits_errados.total/numero_bits_total);
            disp([num2str(bits_errados.total),' wrong bit(s) (BER = ',num2str(BER*100),'%)']);
            disp([num2str(bits_errados.R),' of which came from the red emitter.']);
            disp([num2str(bits_errados.G),' of which came from the green emitter.']);
            disp([num2str(bits_errados.B),' of which came from the blue emitter.']);
            disp([num2str(bits_errados.V),' of which came from the violet emitter.']);
        end
        
        if strcmp(mod_select,'Manchester')
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
            xline(57.5,'--',{'Angle'},'LabelOrientation','Horizontal');
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
            xline(57.5,'--',{'Angle'},'LabelOrientation','Horizontal');
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
            if strcmp(mod_select,'OOK')
                %
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
                xline(57.5,'--',{'Angle'},'LabelOrientation','Horizontal');
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
                ylim([0 18.5])
                xline(0,'--',{'Sync'},'LabelOrientation','Horizontal');
                xline(5.5,'--',{'Calibration Curve'},'LabelOrientation','Horizontal');
                xline(37.5,'--',{'x'},'LabelOrientation','Horizontal');
                xline(41.5,'--',{'y'},'LabelOrientation','Horizontal');
                xline(45.5,'--',{'z'},'LabelOrientation','Horizontal');
                xline(49.5,'--',{'Pin_1'},'LabelOrientation','Horizontal');
                xline(53.5,'--',{'Pin_2'},'LabelOrientation','Horizontal');
                xline(57.5,'--',{'Angle'},'LabelOrientation','Horizontal');
                xline(61.5,'--',{'PL'},'LabelOrientation','Horizontal');
                xticks([1 5 21 37 41 45 49 53 57 61 64])
                yticks([0 5 10 15]+1)
                yticklabels({'0','5','10','15'})
                xlabel('Frame bit')
                ylabel('Decoded level')
                %set(gcf, 'Position',  [100, 100, 1250, 600])%800 600
                set(gcf, 'Position',  [100, 100, 1600, 600])
            else
                error('X');
            end
            
        end
        
    end
    
    %------------Representação do Sinal MUX(Data e Paridade)----------------
    if OFFcount~=3
        
        MUX_DS=SR*CR+SG*CG+SB*CB+SV*CV;        %Soma dos sinais transmitidos(Data) * Ganhos dos LEDs RGBV
        MUX_PS=P_r*CR+P_g*CG+P_b*CB+8.5*CV;    %Soma dos sinais paridade (XOR sinais transmitidos) * Ganhos dos LEDs RGB
        
        max_MUX=7.2*CR+7.7*CG+8.2*CB+8.7*CV;
        min_MUX=7*CR+7.5*CG+8*CB+8.5*CV;
        
        Norm_MUX_DS = (MUX_DS - min_MUX) / (max_MUX - min_MUX);
        Norm_MUX_PS = (MUX_PS - min_MUX) / (max_MUX - min_MUX);
        
        
        figure
        subplot(2,1,1);
        if OFFcount==0
            stairs(xx_S_RGBV,5+SR(1,:),'r');
            hold on;
            stairs(xx_S_RGBV,5+SG(1,:),'g');
            stairs(xx_S_RGBV,5+SB(1,:),'b');
            stairs(xx_S_RGBV,5+SV(1,:),'m');
            stairs(xx_S_RGBV,2.5+SR(2,:),'r');
            stairs(xx_S_RGBV,2.5+SG(2,:),'g');
            stairs(xx_S_RGBV,2.5+SB(2,:),'b');
            stairs(xx_S_RGBV,2.5+SV(2,:),'m');
            stairs(xx_S_RGBV,SR(3,:),'r');
            stairs(xx_S_RGBV,SG(3,:),'g');
            stairs(xx_S_RGBV,SB(3,:),'b');
            stairs(xx_S_RGBV,SV(3,:),'m');
        elseif OFFcount==1
            stairs(xx_S_RGBV,2.5+SR(1,:),'r');
            hold on;
            stairs(xx_S_RGBV,2.5+SG(1,:),'g');
            stairs(xx_S_RGBV,2.5+SB(1,:),'b');
            stairs(xx_S_RGBV,2.5+SV(1,:),'m');
            stairs(xx_S_RGBV,SR(2,:),'r');
            stairs(xx_S_RGBV,SG(2,:),'g');
            stairs(xx_S_RGBV,SB(2,:),'b');
            stairs(xx_S_RGBV,SV(2,:),'m');
        elseif OFFcount==2
            if P_OFF==1
                stairs(xx_S_RGBV,SR(1,:),'r');
                hold on;
                stairs(xx_S_RGBV,SG(1,:),'g');
                stairs(xx_S_RGBV,SB(1,:),'b');
                stairs(xx_S_RGBV,SV(1,:),'m');
            else
                stairs(xx_S_RGBV,2.5+SR(1,:),'r');
                hold on;
                stairs(xx_S_RGBV,2.5+SG(1,:),'g');
                stairs(xx_S_RGBV,2.5+SB(1,:),'b');
                stairs(xx_S_RGBV,2.5+SV(1,:),'m');
                stairs(xx_S_RGBV,P_r(1,:),'r');
                stairs(xx_S_RGBV,P_g(1,:),'g');
                stairs(xx_S_RGBV,P_b(1,:),'b');
                stairs(xx_S_RGBV,P_v(1,:),'m');
            end
        end
        
        for i=1:3
            if (OFFcount==i-1)
                if OFFcount==2 && P_OFF==0
                    text(xx_S_RGBV(4), Y_textT(2), 'Sync', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(8), Y_textT(2), 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(12), Y_textT(2), 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(16), Y_textT(2), 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(20), Y_textT(2), 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(24), Y_textT(2), 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(28), Y_textT(2), 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(47), Y_textT(2), 'Payload Data', 'HorizontalAlignment', 'center','YLimInclude', 'off');
                    
                    
                else
                    text(xx_S_RGBV(4), Y_textT(i), 'Sync', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(8), Y_textT(i), 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(12), Y_textT(i), 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(16), Y_textT(i), 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(20), Y_textT(i), 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(24), Y_textT(i), 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(28), Y_textT(i), 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                    text(xx_S_RGBV(47), Y_textT(i), 'Payload Data', 'HorizontalAlignment', 'center','YLimInclude', 'off');
                end
            end
        end
        
        xline(xx_S_RGBV(6), 'color', 'k', 'LineStyle', '--' );
        xline(xx_S_RGBV(10), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(14), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(18), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(22), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(26), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(30), 'color', 'k', 'LineStyle', '--');
        
        hold off;
        title({'Sinal Transmitido (Teórico)';''});
        xlabel('Tempo [ms]');
        set(gca,'YTickLabel',[]);
        xlim([0 5.04])
        %---------------------------------------------------
        subplot(2,1,2);
        if OFFcount==0
            stairs(xx_S_RGBV,Norm_MUX_DS(1,:));
            hold on;
            stairs(xx_S_RGBV,Norm_MUX_DS(2,:));
            stairs(xx_S_RGBV,Norm_MUX_DS(3,:));
        elseif OFFcount==1
            stairs(xx_S_RGBV,Norm_MUX_DS(1,:));
            hold on;
            stairs(xx_S_RGBV,Norm_MUX_DS(2,:));
        elseif OFFcount==2
            stairs(xx_S_RGBV,Norm_MUX_DS(1,:));
            hold on;
            if P_OFF==0
                stairs(xx_S_RGBV,Norm_MUX_PS(1,:));
            end
        end
        
        xline(xx_S_RGBV(6), 'color', 'k', 'LineStyle', '--' );
        xline(xx_S_RGBV(10), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(14), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(18), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(22), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(26), 'color', 'k', 'LineStyle', '--');
        xline(xx_S_RGBV(30), 'color', 'k', 'LineStyle', '--');
        
        text(xx_S_RGBV(4), 1.14 , 'Sync', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(xx_S_RGBV(8), 1.14, 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(xx_S_RGBV(12), 1.14, 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(xx_S_RGBV(16), 1.14, 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(xx_S_RGBV(20), 1.14, 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(xx_S_RGBV(24), 1.14, 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(xx_S_RGBV(28), 1.14, 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(xx_S_RGBV(47), 1.14, 'Payload Data', 'HorizontalAlignment', 'center','YLimInclude', 'off');
        
        title({'Sinal MUX Recebido (Teórico)';''});
        xlabel('Tempo [ms]');
        ylabel('Intensidade Normalizada');
        
        if OFFcount==0
            legend({'S1','S2','S3'},'Location', 'Best');
        elseif OFFcount==1
            legend({'S1','S2'},'Location', 'Best');
        elseif OFFcount==2
            if P_OFF==1
                legend({'S1'},'Location', 'Best');
            else
                legend({'S_S_T_D','S_P'},'Location', 'Best');
            end
        end
        ylim([0 1.1])
        xlim([0 5.04])
        hold off;
    end
    %------------CM Representação do Sinal MUX(Data)----------------
    if CM_OFFcount~=3
        
        CM_MUX_DS=CM_SR*CR+CM_SG*CG+CM_SB*CB+CM_SV*CV; %Soma dos sinais transmitidos(Data) * Ganhos dos LEDs RGBV
        
        CM_max_MUX=7.2*CR+7.7*CG+8.2*CB+8.7*CV;
        CM_min_MUX=7*CR+7.5*CG+8*CB+8.5*CV;
        
        CM_Norm_MUX_DS = (CM_MUX_DS - CM_min_MUX) / (CM_max_MUX - CM_min_MUX);
        
        figure
        subplot(2,1,1);
        if CM_OFFcount==0
            stairs(CM_xx_S_RGBV,5+CM_SR(1,:),'r');
            hold on;
            stairs(CM_xx_S_RGBV,5+CM_SG(1,:),'g');
            stairs(CM_xx_S_RGBV,5+CM_SB(1,:),'b');
            stairs(CM_xx_S_RGBV,5+CM_SV(1,:),'m');
            stairs(CM_xx_S_RGBV,2.5+CM_SR(2,:),'r');
            stairs(CM_xx_S_RGBV,2.5+CM_SG(2,:),'g');
            stairs(CM_xx_S_RGBV,2.5+CM_SB(2,:),'b');
            stairs(CM_xx_S_RGBV,2.5+CM_SV(2,:),'m');
            stairs(CM_xx_S_RGBV,CM_SR(3,:),'r');
            stairs(CM_xx_S_RGBV,CM_SG(3,:),'g');
            stairs(CM_xx_S_RGBV,CM_SB(3,:),'b');
            stairs(CM_xx_S_RGBV,CM_SV(3,:),'m');
        elseif CM_OFFcount==1
            stairs(CM_xx_S_RGBV,2.5+CM_SR(1,:),'r');
            hold on;
            stairs(CM_xx_S_RGBV,2.5+CM_SG(1,:),'g');
            stairs(CM_xx_S_RGBV,2.5+CM_SB(1,:),'b');
            stairs(CM_xx_S_RGBV,2.5+CM_SV(1,:),'m');
            stairs(CM_xx_S_RGBV,CM_SR(2,:),'r');
            stairs(CM_xx_S_RGBV,CM_SG(2,:),'g');
            stairs(CM_xx_S_RGBV,CM_SB(2,:),'b');
            stairs(CM_xx_S_RGBV,CM_SV(2,:),'m');
        elseif CM_OFFcount==2
            stairs(CM_xx_S_RGBV,CM_SR(1,:),'r');
            hold on;
            stairs(CM_xx_S_RGBV,CM_SG(1,:),'g');
            stairs(CM_xx_S_RGBV,CM_SB(1,:),'b');
            stairs(CM_xx_S_RGBV,CM_SV(1,:),'m');
        end
        
        for j=1:3
            if (CM_OFFcount==j-1)
                text(CM_xx_S_RGBV(4), Y_textT(j) , 'Sync', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                text(CM_xx_S_RGBV(8), Y_textT(j),  'CM', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                text(CM_xx_S_RGBV(12), Y_textT(j), 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                text(CM_xx_S_RGBV(16), Y_textT(j), 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                text(CM_xx_S_RGBV(20), Y_textT(j), 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                text(CM_xx_S_RGBV(24), Y_textT(j), 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                text(CM_xx_S_RGBV(28), Y_textT(j), 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
                text(CM_xx_S_RGBV(32), Y_textT(j), 'ANGLE', 'HorizontalAlignment', 'center','YLimInclude', 'off');
                text(CM_xx_S_RGBV(49), Y_textT(j), 'Payload Data', 'HorizontalAlignment', 'center','YLimInclude', 'off');
            end
        end
        
        xline(CM_xx_S_RGBV(6), 'color', 'k', 'LineStyle', '--' );
        xline(CM_xx_S_RGBV(10), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(14), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(18), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(22), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(26), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(30), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(34), 'color', 'k', 'LineStyle', '--');
        
        hold off;
        title({'Sinal Transmitido CM (Teórico)';''});
        xlabel('Tempo [ms]');
        set(gca,'YTickLabel',[]);
        xlim([0 5.04])
        %-----------------------------------------------
        subplot(2,1,2);
        if CM_OFFcount==0
            stairs(CM_xx_S_RGBV,CM_Norm_MUX_DS(1,:));
            hold on;
            stairs(CM_xx_S_RGBV,CM_Norm_MUX_DS(2,:));
            stairs(CM_xx_S_RGBV,CM_Norm_MUX_DS(3,:));
        elseif CM_OFFcount==1
            stairs(CM_xx_S_RGBV,CM_Norm_MUX_DS(1,:));
            hold on;
            stairs(CM_xx_S_RGBV,CM_Norm_MUX_DS(2,:));
        elseif CM_OFFcount==2
            stairs(CM_xx_S_RGBV,CM_Norm_MUX_DS(1,:));
            hold on;
        end
        
        xline(CM_xx_S_RGBV(6), 'color', 'k', 'LineStyle', '--' );
        xline(CM_xx_S_RGBV(10), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(14), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(18), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(22), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(26), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(30), 'color', 'k', 'LineStyle', '--');
        xline(CM_xx_S_RGBV(34), 'color', 'k', 'LineStyle', '--');
        
        text(CM_xx_S_RGBV(4), 1.14 , 'Sync', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(CM_xx_S_RGBV(8), 1.14, 'CM', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(CM_xx_S_RGBV(12), 1.14, 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(CM_xx_S_RGBV(16), 1.14, 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(CM_xx_S_RGBV(20), 1.14, 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(CM_xx_S_RGBV(24), 1.14, 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(CM_xx_S_RGBV(28), 1.14, 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(CM_xx_S_RGBV(32), 1.14, 'ANGLE', 'HorizontalAlignment', 'center','YLimInclude', 'off');
        text(CM_xx_S_RGBV(49), 1.14, 'Payload Data', 'HorizontalAlignment', 'center','YLimInclude', 'off');
        
        title({'Sinal MUX Recebido CM (Teórico)';''});
        xlabel('Tempo [ms]');
        ylabel('Intensidade Normalizada');
        if CM_OFFcount==0
            legend({'S1','S2','S3'},'Location', 'Best');
        elseif CM_OFFcount==1
            legend({'S1','S2'},'Location', 'Best');
        elseif CM_OFFcount==2
            legend({'S1'},'Location', 'Best');
        end
        ylim([0 1.1])
        xlim([0 5.04])
        hold off;
    end
    %%-------------------------Descodificação-------------------------
    if OFFcount~=3
        fp=zeros(1,SR_Y);
        id_x=zeros(4,SR_Y);
        id_y=zeros(4,SR_Y);
        id_z=zeros(4,SR_Y);
        pin2=zeros(4,SR_Y);
        angle=zeros(4,SR_Y);
        pd=zeros(35,SR_Y);
        
        for i=1:SR_Y
            
            %---------Sync---------
            fp(1,i) = interp1(yy_stairs,yy_stairs,Norm_MUX_DS(i,1),'nearest');
            %----------ID----------
            count=1;
            for j=6:9
                id_x(count,i) = interp1(yy_stairs,yy_stairs,Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            count=1;
            for j=10:13
                id_y(count,i) = interp1(yy_stairs,yy_stairs,Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            count=1;
            for j=14:17
                id_z(count,i) = interp1(yy_stairs,yy_stairs,Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %--------Pin2--------
            count=1;
            for j=22:25
                pin2(count,i) = interp1(yy_stairs,yy_stairs,Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %--------Angle--------
            count=1;
            for j=26:29
                angle(count,i) = interp1(yy_stairs,yy_stairs,Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %----Payload Data----
            count=1;
            for j=30:length(SR)
                pd(count,i) = interp1(yy_stairs,yy_stairs,Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
        end
        
        %-------------------
        FP=zeros(1,SR_Y);
        temp_ID_x=zeros(length(id_x),SR_Y);
        temp_ID_y=zeros(length(id_y),SR_Y);
        temp_ID_z=zeros(length(id_z),SR_Y);
        temp_PIN2=zeros(length(pin2),SR_Y);
        temp_ANGLE=zeros(length(angle),SR_Y);
        temp_PD=zeros(length(pd),SR_Y);
        
        for z=1:SR_Y
            
            for i=1:length(yy_stairs)
                %Sync
                if (fp(z)==yy_stairs(i))
                    FP(1,z)=i-1;
                end
                %ID
                for k=1:length(id_x)
                    if (id_x(k,z)==yy_stairs(i))
                        temp_ID_x(k,z)=i-1;
                    end
                end
                for k=1:length(id_y)
                    if (id_y(k,z)==yy_stairs(i))
                        temp_ID_y(k,z)=i-1;
                    end
                end
                for k=1:length(id_z)
                    if (id_z(k,z)==yy_stairs(i))
                        temp_ID_z(k,z)=i-1;
                    end
                end
                %PIN2
                for k=1:length(pin2)
                    if (pin2(k,z)==yy_stairs(i))
                        temp_PIN2(k,z)=i-1;
                    end
                end
                %Angle
                for k=1:length(angle)
                    if (angle(k,z)==yy_stairs(i))
                        temp_ANGLE(k,z)=i-1;
                    end
                end
                %PD
                for k=1:length(pd)
                    if (pd(k,z)==yy_stairs(i))
                        temp_PD(k,z)=i-1;
                    end
                end
            end
        end
        
        %---------Sync---------
        for j=1:SR_Y
            if FP(1,j)==15
                FP(1,j)=1;
                LED_select=1;
            elseif FP(1,j)==14
                FP(1,j)=2;
                LED_select=1;
            elseif FP(1,j)==13
                FP(1,j)=8;
                LED_select=1;
            elseif FP(1,j)==12
                FP(1,j)=9;
                LED_select=1;
            elseif FP(1,j)==11
                FP(1,j)=4;
                LED_select=1;
            elseif FP(1,j)==10
                FP(1,j)=3;
                LED_select=1;
            elseif FP(1,j)==7
                FP(1,j)=6;
                LED_select=2;
            elseif FP(1,j)==5
                FP(1,j)=7;
                LED_select=2;
            elseif FP(1,j)==3
                FP(1,j)=5;
                LED_select=3;
            end
            
        end
        
        %----------ID----------
        ID_x=dec2bin(temp_ID_x,4);
        ID_y=dec2bin(temp_ID_y,4);
        ID_z=dec2bin(temp_ID_z,4);
        
        i=1;
        a=1;
        for j=1:SR_Y
            
            R_ID_x(j,:)=ID_x(a:4*i,1);
            G_ID_x(j,:)=ID_x(a:4*i,2);
            B_ID_x(j,:)=ID_x(a:4*i,3);
            V_ID_x(j,:)=ID_x(a:4*i,4);
            
            R_ID_y(j,:)=ID_y(a:4*i,1);
            G_ID_y(j,:)=ID_y(a:4*i,2);
            B_ID_y(j,:)=ID_y(a:4*i,3);
            V_ID_y(j,:)=ID_y(a:4*i,4);
            
            R_ID_z(j,:)=ID_z(a:4*i,1);
            G_ID_z(j,:)=ID_z(a:4*i,2);
            B_ID_z(j,:)=ID_z(a:4*i,3);
            V_ID_z(j,:)=ID_z(a:4*i,4);
            
            a=(4*i)+1;
            i=i+1;
        end
        
        %--------Pin2--------
        temp2_PIN2=dec2bin(temp_PIN2,4);
        
        PIN2(1,:)=temp2_PIN2(1:4,LED_select);
        PIN2(2,:)=temp2_PIN2(5:8,LED_select);
        PIN2(3,:)=temp2_PIN2(9:12,LED_select);
        
        %--------Angle--------
        temp2_ANGLE=dec2bin(temp_ANGLE,4);
        
        ANGLE_CODE(1,:)=temp2_ANGLE(1:4,LED_select);
        ANGLE_CODE(2,:)=temp2_ANGLE(5:8,LED_select);
        ANGLE_CODE(3,:)=temp2_ANGLE(9:12,LED_select);
        
        ANGLE=zeros(3,1);
        
        for j=1:3
            if bin2dec(ANGLE_CODE(j,:))==2
                ANGLE(j,1)=315;
            elseif bin2dec(ANGLE_CODE(j,:))==3
                ANGLE(j,1)=0;
            elseif bin2dec(ANGLE_CODE(j,:))==4
                ANGLE(j,1)=45;
            elseif bin2dec(ANGLE_CODE(j,:))==5
                ANGLE(j,1)=90;
            elseif bin2dec(ANGLE_CODE(j,:))==6
                ANGLE(j,1)=135;
            elseif bin2dec(ANGLE_CODE(j,:))==7
                ANGLE(j,1)=180;
            elseif bin2dec(ANGLE_CODE(j,:))==8
                ANGLE(j,1)=225;
            elseif bin2dec(ANGLE_CODE(j,:))==9
                ANGLE(j,1)=270;
            else
                ANGLE(j,1)=str2double('-');
            end
        end
        
        %----Payload Data----
        PD=dec2bin(temp_PD,4);
        
        i=1;
        a=1;
        for j=1:SR_Y
            
            PD_R(j,:)=PD(a:35*i,1);
            PD_G(j,:)=PD(a:35*i,2);
            PD_B(j,:)=PD(a:35*i,3);
            PD_V(j,:)=PD(a:35*i,4);
            
            a=(35*i)+1;
            i=i+1;
        end
    end
    %%-------------------------Descodifcação CM-------------------------
    if CM_OFFcount~=3
        fp=zeros(1,CMSR_Y);
        cm=zeros(1,CMSR_Y);
        id_x=zeros(4,CMSR_Y);
        id_y=zeros(4,CMSR_Y);
        id_z=zeros(4,CMSR_Y);
        pin1=zeros(4,CMSR_Y);
        pin2=zeros(4,CMSR_Y);
        angle=zeros(4,CMSR_Y);
        pd=zeros(31,CMSR_Y);
        
        for i=1:CMSR_Y
            
            %---------Sync---------
            fp(1,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,1),'nearest');
            %----------CM----------
            count=1;
            for j=6:9
                cm(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %----------ID----------
            count=1;
            for j=10:13
                id_x(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            count=1;
            for j=14:17
                id_y(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            count=1;
            for j=18:21
                id_z(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %--------Pin1--------
            count=1;
            for j=22:25
                pin1(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %--------Pin2--------
            count=1;
            for j=26:29
                pin2(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %--------Angle--------
            count=1;
            for j=30:33
                angle(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
            %----Payload Data----
            count=1;
            for j=34:length(CM_SR)
                pd(count,i) = interp1(yy_stairs,yy_stairs,CM_Norm_MUX_DS(i,j),'nearest');
                count=count+1;
            end
        end
        
        %-------------------
        FP=zeros(1,CMSR_Y);
        temp_CM=zeros(length(cm),CMSR_Y);
        temp_ID_x=zeros(length(id_x),CMSR_Y);
        temp_ID_y=zeros(length(id_y),CMSR_Y);
        temp_ID_z=zeros(length(id_z),CMSR_Y);
        temp_PIN1=zeros(length(pin1),CMSR_Y);
        temp_PIN2=zeros(length(pin2),CMSR_Y);
        temp_ANGLE=zeros(length(angle),CMSR_Y);
        temp_PD=zeros(length(pd),CMSR_Y);
        
        for z=1:CMSR_Y
            
            for i=1:length(yy_stairs)
                %Sync
                if (fp(z)==yy_stairs(i))
                    FP(1,z)=i-1;
                end
                %CM
                for k=1:length(cm)
                    if (cm(k,z)==yy_stairs(i))
                        temp_CM(k,z)=i-1;
                    end
                end
                %ID
                for k=1:length(id_x)
                    if (id_x(k,z)==yy_stairs(i))
                        temp_ID_x(k,z)=i-1;
                    end
                end
                for k=1:length(id_y)
                    if (id_y(k,z)==yy_stairs(i))
                        temp_ID_y(k,z)=i-1;
                    end
                end
                for k=1:length(id_z)
                    if (id_z(k,z)==yy_stairs(i))
                        temp_ID_z(k,z)=i-1;
                    end
                end
                %PIN1
                for k=1:length(pin1)
                    if (pin1(k,z)==yy_stairs(i))
                        temp_PIN1(k,z)=i-1;
                    end
                end
                %PIN2
                for k=1:length(pin2)
                    if (pin2(k,z)==yy_stairs(i))
                        temp_PIN2(k,z)=i-1;
                    end
                end
                %Angle
                for k=1:length(angle)
                    if (angle(k,z)==yy_stairs(i))
                        temp_ANGLE(k,z)=i-1;
                    end
                end
                %PD
                for k=1:length(pd)
                    if (pd(k,z)==yy_stairs(i))
                        temp_PD(k,z)=i-1;
                    end
                end
            end
        end
        
        %---------Sync---------
        for j=1:CMSR_Y
            if FP(1,j)==15
                FP(1,j)=1;
                LED_select=1;
            elseif FP(1,j)==14
                FP(1,j)=2;
                LED_select=1;
            elseif FP(1,j)==13
                FP(1,j)=8;
                LED_select=1;
            elseif FP(1,j)==12
                FP(1,j)=9;
                LED_select=1;
            elseif FP(1,j)==11
                FP(1,j)=4;
                LED_select=1;
            elseif FP(1,j)==10
                FP(1,j)=3;
                LED_select=1;
            elseif FP(1,j)==7
                FP(1,j)=6;
                LED_select=2;
            elseif FP(1,j)==5
                FP(1,j)=7;
                LED_select=2;
            elseif FP(1,j)==3
                FP(1,j)=5;
                LED_select=3;
            end
            
        end
        
        %---------CM---------
        temp2_CM=dec2bin(temp_CM);
        
        CM(1,:)=temp2_CM(1:4,LED_select);
        CM(2,:)=temp2_CM(5:8,LED_select);
        CM(3,:)=temp2_CM(9:12,LED_select);
        
        %----------ID----------
        CM_ID_x=dec2bin(temp_ID_x,4);
        CM_ID_y=dec2bin(temp_ID_y,4);
        CM_ID_z=dec2bin(temp_ID_z,4);
        
        i=1;
        a=1;
        for j=1:CMSR_Y
            
            CM_R_ID_x(j,:)=CM_ID_x(a:4*i,1);
            CM_G_ID_x(j,:)=CM_ID_x(a:4*i,2);
            CM_B_ID_x(j,:)=CM_ID_x(a:4*i,3);
            CM_V_ID_x(j,:)=CM_ID_x(a:4*i,4);
            
            CM_R_ID_y(j,:)=CM_ID_y(a:4*i,1);
            CM_G_ID_y(j,:)=CM_ID_y(a:4*i,2);
            CM_B_ID_y(j,:)=CM_ID_y(a:4*i,3);
            CM_V_ID_y(j,:)=CM_ID_y(a:4*i,4);
            
            CM_R_ID_z(j,:)=CM_ID_z(a:4*i,1);
            CM_G_ID_z(j,:)=CM_ID_z(a:4*i,2);
            CM_B_ID_z(j,:)=CM_ID_z(a:4*i,3);
            CM_V_ID_z(j,:)=CM_ID_z(a:4*i,4);
            
            a=(4*i)+1;
            i=i+1;
        end
        
        %--------Pin1--------
        CM_PIN1=dec2bin(temp_PIN1);
        
        i=1;
        a=1;
        for j=1:CMSR_Y
            
            CM_PIN1_R(j,:)=CM_PIN1(a:4*i,1);
            CM_PIN1_G(j,:)=CM_PIN1(a:4*i,2);
            CM_PIN1_B(j,:)=CM_PIN1(a:4*i,3);
            CM_PIN1_V(j,:)=CM_PIN1(a:4*i,4);
            
            a=(4*i)+1;
            i=i+1;
        end
        
        %--------Pin2--------
        temp_CM_PIN2=dec2bin(temp_PIN2);
        
        CM_PIN2(1,:)=temp_CM_PIN2(1:4,LED_select);
        CM_PIN2(2,:)=temp_CM_PIN2(5:8,LED_select);
        CM_PIN2(3,:)=temp_CM_PIN2(9:12,LED_select);
        
        %--------Angle--------
        temp_CM_ANGLE=dec2bin(temp_ANGLE);
        
        CM_ANGLE_CODE(1,:)=temp_CM_ANGLE(1:4,LED_select);
        CM_ANGLE_CODE(2,:)=temp_CM_ANGLE(5:8,LED_select);
        CM_ANGLE_CODE(3,:)=temp_CM_ANGLE(9:12,LED_select);
        
        ANGLE=zeros(3,1);
        
        for j=1:3
            if bin2dec(CM_ANGLE_CODE(j,:))==2
                ANGLE(j,1)=315;
            elseif bin2dec(CM_ANGLE_CODE(j,:))==3
                ANGLE(j,1)=0;
            elseif bin2dec(CM_ANGLE_CODE(j,:))==4
                ANGLE(j,1)=45;
            elseif bin2dec(CM_ANGLE_CODE(j,:))==5
                ANGLE(j,1)=90;
            elseif bin2dec(CM_ANGLE_CODE(j,:))==6
                ANGLE(j,1)=135;
            elseif bin2dec(CM_ANGLE_CODE(j,:))==7
                ANGLE(j,1)=180;
            elseif bin2dec(CM_ANGLE_CODE(j,:))==8
                ANGLE(j,1)=225;
            elseif bin2dec(CM_ANGLE_CODE(j,:))==9
                ANGLE(j,1)=270;
            else
                ANGLE(j,1)=str2double('-');
            end
        end
        
        %----Payload Data----
        CM_PD=dec2bin(temp_PD);
        
        i=1;
        a=1;
        
        for j=1:CMSR_Y
            
            CM_PD_R(j,:)=CM_PD(a:31*i,1);
            CM_PD_G(j,:)=CM_PD(a:31*i,2);
            CM_PD_B(j,:)=CM_PD(a:31*i,3);
            CM_PD_V(j,:)=CM_PD(a:31*i,4);
            
            a=(31*i)+1;
            i=i+1;
        end
        
        fprintf('-------------------------Início da Descodificação CM "ideal"------------------------\n')
        if CM_OFFcount==0
            for i=1:3
                if i==1
                    fprintf('<strong>**CM S1**</strong>\n')
                elseif i==2
                    fprintf('<strong>**CM S2**</strong>\n')
                else
                    fprintf('<strong>**CM S3**</strong>\n')
                end
                
                fprintf('Sync:  #%i\n',FP(:,i))
                fprintf('CM:    %d\n',bin2dec(CM(i,:)))
                fprintf('ID:    R(%d,%d,%d) G(%d,%d,%d) B(%d,%d,%d) V(%d,%d,%d)\n',bin2dec(CM_R_ID_x(i,:)),bin2dec(CM_R_ID_y(i,:)),bin2dec(CM_R_ID_z(i,:)),bin2dec(CM_G_ID_x(i,:)),bin2dec(CM_G_ID_y(i,:)),bin2dec(CM_G_ID_z(i,:)),bin2dec(CM_B_ID_x(i,:)),bin2dec(CM_B_ID_y(i,:)),bin2dec(CM_B_ID_z(i,:)),bin2dec(CM_V_ID_x(i,:)),bin2dec(CM_V_ID_y(i,:)),bin2dec(CM_V_ID_z(i,:)))
                fprintf('PIN1:  %d%d%d%d\n',bin2dec(CM_PIN1_R(i,:)),bin2dec(CM_PIN1_G(i,:)),bin2dec(CM_PIN1_B(i,:)),bin2dec(CM_PIN1_V(i,:)) )
                fprintf('PIN2:  %d\n',bin2dec(CM_PIN2(i,:)))
                fprintf('Angle: Code %d (%dº)\n',bin2dec(CM_ANGLE_CODE(i,:)),ANGLE(i,:))
                fprintf('PD:    R(%s) G(%s) \n       B(%s) V(%s)\n',CM_PD_R(i,:),CM_PD_G(i,:),CM_PD_B(i,:),CM_PD_V(i,:))
            end
        elseif CM_OFFcount==1
            for i=1:2
                if i==1
                    fprintf('<strong>**CM S1**</strong>\n')
                else
                    fprintf('<strong>**CM S2**</strong>\n')
                end
                
                fprintf('Sync:  #%i\n',FP(:,i))
                fprintf('CM:    %d\n',bin2dec(CM(i,:)))
                fprintf('ID:    R(%d,%d,%d) G(%d,%d,%d) B(%d,%d,%d) V(%d,%d,%d)\n',bin2dec(CM_R_ID_x(i,:)),bin2dec(CM_R_ID_y(i,:)),bin2dec(CM_R_ID_z(i,:)),bin2dec(CM_G_ID_x(i,:)),bin2dec(CM_G_ID_y(i,:)),bin2dec(CM_G_ID_z(i,:)),bin2dec(CM_B_ID_x(i,:)),bin2dec(CM_B_ID_y(i,:)),bin2dec(CM_B_ID_z(i,:)),bin2dec(CM_V_ID_x(i,:)),bin2dec(CM_V_ID_y(i,:)),bin2dec(CM_V_ID_z(i,:)))
                fprintf('PIN1:  %d%d%d%d\n',bin2dec(CM_PIN1_R(i,:)),bin2dec(CM_PIN1_G(i,:)),bin2dec(CM_PIN1_B(i,:)),bin2dec(CM_PIN1_V(i,:)) )
                fprintf('PIN2:  %d\n',bin2dec(CM_PIN2(i,:)))
                fprintf('Angle: Code %d (%dº)\n',bin2dec(CM_ANGLE_CODE(i,:)),ANGLE(i,:))
                fprintf('PD:    R(%s) G(%s) \n       B(%s) V(%s)\n',CM_PD_R(i,:),CM_PD_G(i,:),CM_PD_B(i,:),CM_PD_V(i,:))
            end
        elseif CM_OFFcount==2
            fprintf('<strong>**CM S1**</strong>\n')
            fprintf('Sync:  #%i\n',FP(:,1))
            fprintf('CM:    %d\n',bin2dec(CM(1,:)))
            fprintf('ID:    R(%d,%d,%d) G(%d,%d,%d) B(%d,%d,%d) V(%d,%d,%d)\n',bin2dec(CM_R_ID_x(1,:)),bin2dec(CM_R_ID_y(1,:)),bin2dec(CM_R_ID_z(1,:)),bin2dec(CM_G_ID_x(1,:)),bin2dec(CM_G_ID_y(1,:)),bin2dec(CM_G_ID_z(1,:)),bin2dec(CM_B_ID_x(1,:)),bin2dec(CM_B_ID_y(1,:)),bin2dec(CM_B_ID_z(1,:)),bin2dec(CM_V_ID_x(1,:)),bin2dec(CM_V_ID_y(1,:)),bin2dec(CM_V_ID_z(1,:)))
            fprintf('PIN1:  %d%d%d%d\n',bin2dec(CM_PIN1_R(1,:)),bin2dec(CM_PIN1_G(1,:)),bin2dec(CM_PIN1_B(1,:)),bin2dec(CM_PIN1_V(1,:)) )
            fprintf('PIN2:  %d\n',bin2dec(CM_PIN2(1,:)))
            fprintf('Angle: Code %d (%dº)\n',bin2dec(CM_ANGLE_CODE(1,:)),ANGLE(1,:))
            fprintf('PD:    R(%s) G(%s) \n       B(%s) V(%s)\n',CM_PD_R(1,:),CM_PD_G(1,:),CM_PD_B(1,:),CM_PD_V(1,:))
        end
        fprintf('--------------------------Fim da Descodificação CM "ideal"--------------------------\n\n')
    end
end
    % --- SHUTDOWN ---
    if D_ON==0
        if capacitive_select
            if parity_select
                close 5
            else
                close 2
            end
        else
            if parity_select
                close 5
            else
                close 2
            end
        end
    else
    end
%     if (parity_select==1) && (D_ON==0)
%         %close 3 4 8
%     elseif (parity_select==0) && (D_ON==0)
%         %close 3 4 5
%     end
end