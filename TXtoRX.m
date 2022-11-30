function TXtoRX (FName1, SR_TX, SG_TX, SB_TX, SV_TX, DeltaT, BER_FLAG,CC_FLAG,imported_excel)

%O Rodrigues chama a isto "TXtoRX", mas na verdade devia ser "RXtoTX"!

%%------------------***Normalização da STD e PARITY STD***-----------------
data_STD_PARITY = readmatrix('JOAO_R TESTE1 front 17 NOV.xlsx','Sheet','STD_PARITY');
data_STD = readmatrix('JOAO_R TESTE1 front 17 NOV.xlsx','Sheet','STD');

STD = data_STD(38:245,20);
STD_PARITY = data_STD_PARITY(38:245,16);

STD2(1,:)=STD;
y_stairs_STD = (STD2- min(STD2)) / ( max(STD2) - min(STD2));
T_STD = data_STD(1:length(y_stairs_STD))*10^3;

STD_PARITY2(1,:)=STD_PARITY;
y_stairs_STD_P = (STD_PARITY2- min(STD_PARITY2)) / ( max(STD2) - min(STD_PARITY2));

STD_Final=data_STD(39:54,24);
y_stairs_STD_Final = (STD_Final- min(STD_Final)) / ( max(STD_Final) - min(STD_Final));
T_STD_Final = (0:length(y_stairs_STD_Final))*(DeltaT);

STD_P=data_STD_PARITY(39:54,26);
for i=1:2:length(STD_Final)
    STD_P_Final(i) = interp1(STD_P,STD_P,STD_Final(i),'nearest','extrap');
end
STD_P_Final=STD_P_Final(STD_P_Final~=0);

y_stairs_STD_Patiry = sort((STD_P_Final- min(STD_P_Final)) / (max(STD_Final) - min(STD_P_Final)));
T_STD_Patiry = (0:(length(y_stairs_STD_Patiry)))*(DeltaT);

STD_P_Final2=data_STD_PARITY(39:54,26);
y_stairs_STD_Patiry2 = (STD_P_Final2- min(STD_P_Final2)) / (max(STD_Final) - min(STD_P_Final2));
T_STD_Patiry2 = (0:(length(y_stairs_STD_Patiry2)))*(DeltaT);

%---------------***Normalização dos Sinais RX e RX PARITY***---------------
sFName1=size(FName1);
Fname1_y=sFName1(1);

MAX_DATA = readmatrix('JOAO_R TESTE1 front 17 NOV.xlsx','Sheet','B#1C(4,3,1)7261');

for j=1:Fname1_y
    
    if (contains(FName1(j,:),'B#1C(4,3,1)7261')==1)
        FP(j)=20;
        FName2(j,:)='B#1C(4,3,1)7261_PARITY';
    elseif (contains(FName1(j,:),'B#3C(4,3,1)7261')==1)
        FP(j)=11;
        FName2(j,:)='B#3C(4,3,1)7261_PARITY';
    elseif (contains(FName1(j,:),'B#1C(4,4,1)7261')==1)
        FP(j)=20;
        FName2(j,:)='B#1C(4,4,1)7261_PARITY';
    elseif (contains(FName1(j,:),'B#6C(4,4,1)7261')==1)
        FP(j)=18;
        FName2(j,:)='B#6C(4,4,1)7261_PARITY';
    else
        FP(j)=18;
        FName2(j,:)='B#6C(4,4,1)3009_PARITY';
    end
    
    TxRx_DATA = readmatrix('JOAO_R TESTE1 front 17 NOV.xlsx','Sheet',FName1(j,:));
    TxRx_PARITY = readmatrix('JOAO_R TESTE1 front 17 NOV.xlsx','Sheet',FName2(j,:));
    
    SR_DATA(j,:)=  TxRx_DATA(5:211,2);
    SG_DATA(j,:)=  TxRx_DATA(5:211,3);
    SB_DATA(j,:)=  TxRx_DATA(5:211,4);
    SV_DATA(j,:)=  TxRx_DATA(5:211,5);
    MUX_DATA(j,:)= TxRx_DATA(5:211,FP(j));
    
    SR_PARITY(j,:)=  TxRx_PARITY(5:211,2);
    SG_PARITY(j,:)=  TxRx_PARITY(5:211,3);
    SB_PARITY(j,:)=  TxRx_PARITY(5:211,4);
    SV_PARITY(j,:)=  TxRx_PARITY(5:211,5);
    MUX_PARITY(j,:)= TxRx_PARITY(5:211,16);
    
    if (contains(FName1(j,:),'B#1C(4,4,1)7261')==1)
        MAX_D(:,1)= TxRx_DATA(13:44,26);
        MAX_D2(1,:)=  TxRx_DATA(5:207,20);
    else
        MAX_D(:,1)=  MAX_DATA(13:44,26);
        MAX_D2(1,:)=  MAX_DATA(5:207,20);
    end
    
    Rx_DATA=  TxRx_DATA(13:44,26);
    Norm_MUX_DS(:,j) = (Rx_DATA - min(Rx_DATA))/(max(MAX_D) - min(Rx_DATA));
    
    Rx_PARITY=TxRx_PARITY(13:44,26);
    Norm_MUX_PS(:,j) = (Rx_PARITY - min(Rx_PARITY))/(max(MAX_D) - min(Rx_PARITY));
    
    for i=1:length(Norm_MUX_DS)
        temp1_DESC_MUX_DS(i,j) = interp1(y_stairs_STD_Final,y_stairs_STD_Final,Norm_MUX_DS(i,j),'nearest','extrap');
    end
    
    for i=1:length(Norm_MUX_PS)
        temp1_DESC_MUX_PS(i,j) = interp1(y_stairs_STD_Patiry,y_stairs_STD_Patiry,Norm_MUX_PS(i,j),'nearest','extrap');
    end
    
    %---------------------------***Descodificação***---------------------------
    for i=1:length(y_stairs_STD_Patiry)
        for k=1:length(temp1_DESC_MUX_PS)
            if (temp1_DESC_MUX_PS(k,j)==y_stairs_STD_Patiry(i))
                temp2_DESC_MUX_PS(k,j)=(i-1)*2;
            end
        end
    end
    
    for i=1:length(y_stairs_STD_Final)
        for k=1:length(temp1_DESC_MUX_DS)
            if (temp1_DESC_MUX_DS(k,j)==y_stairs_STD_Final(i))
                temp2_DESC_MUX_DS(k,j)=i-1;
            end
        end
    end
    
    temp3_DESC_MUX_DS=zeros(length(temp2_DESC_MUX_DS),1);
    
    for i=1:length(temp2_DESC_MUX_DS)
        if temp2_DESC_MUX_PS(i,j)==0 && temp2_DESC_MUX_DS(i,j)~=0 && temp2_DESC_MUX_DS(i,j)~=14
            N=[0 14 7 9];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            if closestValue == 7  || closestValue == 9
                temp2_DESC_MUX_PS(i,j)=2;
                temp3_DESC_MUX_DS(i,j)=interp1([7 9],[7 9],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            else
                temp3_DESC_MUX_DS(i,j)=interp1([0 14],[0 14],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        elseif temp2_DESC_MUX_PS(i,j)==2 && temp2_DESC_MUX_DS(i,j)~=7 && temp2_DESC_MUX_DS(i,j)~=9
            N=[0 7 9 3 13];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            
            if closestValue == 0
                temp2_DESC_MUX_PS(i,j)=0;
                temp3_DESC_MUX_DS(i,j)=0;
            elseif closestValue == 3 || closestValue == 13
                temp2_DESC_MUX_PS(i,j)=4;
                temp3_DESC_MUX_DS(i,j)=interp1([3 13],[3 13],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            else
                temp3_DESC_MUX_DS(i,j)=interp1([7 9],[7 9],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        elseif temp2_DESC_MUX_PS(i,j)==4 && temp2_DESC_MUX_DS(i,j)~=3 && temp2_DESC_MUX_DS(i,j)~=13
            N=[ 7 9 3 13 10];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            
            if closestValue == 7 || closestValue == 9
                temp2_DESC_MUX_PS(i,j)=2;
                temp3_DESC_MUX_DS(i,j)=interp1([7 9],[7 9],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            elseif closestValue == 10
                temp2_DESC_MUX_PS(i,j)=6;
                temp3_DESC_MUX_DS(i,j)=10;
            else
                temp3_DESC_MUX_DS(i,j)=interp1([3 13],[3 13],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        elseif temp2_DESC_MUX_PS(i,j)==6 && temp2_DESC_MUX_DS(i,j)~=4 && temp2_DESC_MUX_DS(i,j)~=10
            N=[13 4 10];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            if closestValue == 13
                temp2_DESC_MUX_PS(i,j)=4;
                temp3_DESC_MUX_DS(i,j)=13;
            else
                temp3_DESC_MUX_DS(i,j)=interp1([4 10],[4 10],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        elseif temp2_DESC_MUX_PS(i,j)==8 && temp2_DESC_MUX_DS(i,j)~=5 && temp2_DESC_MUX_DS(i,j)~=11
            N=[5 11 2];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            if closestValue == 2
                temp2_DESC_MUX_PS(i,j)=10;
                temp3_DESC_MUX_DS(i,j)=2;
            else
                temp3_DESC_MUX_DS(i,j)=interp1([5 11],[5 11],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        elseif temp2_DESC_MUX_PS(i,j)==10 && temp2_DESC_MUX_DS(i,j)~=2 && temp2_DESC_MUX_DS(i,j)~=12
            N=[5 2 12 8];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            if closestValue == 5
                temp2_DESC_MUX_PS(i,j)=8;
                temp3_DESC_MUX_DS(i,j)=5;
            elseif closestValue == 8
                temp2_DESC_MUX_PS(i,j)=12;
                temp3_DESC_MUX_DS(i,j)=8;
            else
                temp3_DESC_MUX_DS(i,j)=interp1([2 12],[2 12],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        elseif temp2_DESC_MUX_PS(i,j)==12 && temp2_DESC_MUX_DS(i,j)~=6 && temp2_DESC_MUX_DS(i,j)~=8
            N=[12 6 8 1 15];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            
            if closestValue == 1 || closestValue == 15
                temp2_DESC_MUX_PS(i,j)=14;
                temp3_DESC_MUX_DS(i,j)=interp1([1 15],[1 15],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            elseif closestValue == 12
                temp2_DESC_MUX_PS(i,j)=10;
                temp3_DESC_MUX_DS(i,j)=12;
            else
                temp3_DESC_MUX_DS(i,j)=interp1([6 8],[6 8],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        elseif temp2_DESC_MUX_PS(i,j)==14 && temp2_DESC_MUX_DS(i,j)~=1 && temp2_DESC_MUX_DS(i,j)~=15
            N=[6 8 1 15];
            [~, closestIndex] = min(abs(N - temp2_DESC_MUX_DS(i,j)));
            closestValue = N(closestIndex);
            
            if closestValue == 6 || closestValue == 8
                temp2_DESC_MUX_PS(i,j)=12;
                temp3_DESC_MUX_DS(i,j)=interp1([6 8],[6 8],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            else
                temp3_DESC_MUX_DS(i,j)=interp1([1 15],[1 15],temp2_DESC_MUX_DS(i,j),'nearest','extrap');
            end
        else
            temp3_DESC_MUX_DS(i,j)= temp2_DESC_MUX_DS(i,j);
        end
    end
    
    DESC_MUX_DS=dec2bin(temp2_DESC_MUX_DS(:,j),4);   %-------> sem intervenção da paridade
    DESC_MUX_DS2=dec2bin(temp3_DESC_MUX_DS(:,j),4);  %-------> com intervenção da paridade
    DESC_MUX_PS=dec2bin(temp2_DESC_MUX_PS(:,j),4);
    
    SR_temp(j,:)=DESC_MUX_DS(:,1);
    SG_temp(j,:)=DESC_MUX_DS(:,2);
    SB_temp(j,:)=DESC_MUX_DS(:,3);
    SV_temp(j,:)=DESC_MUX_DS(:,4);
    
    SR_tempP(j,:)=DESC_MUX_DS2(:,1);
    SG_tempP(j,:)=DESC_MUX_DS2(:,2);
    SB_tempP(j,:)=DESC_MUX_DS2(:,3);
    SV_tempP(j,:)=DESC_MUX_DS2(:,4);
    
    SR_Parity(j,:)=DESC_MUX_PS(:,1);
    SG_Parity(j,:)=DESC_MUX_PS(:,2);
    SB_Parity(j,:)=DESC_MUX_PS(:,3);
    SV_Parity(j,:)=DESC_MUX_PS(:,4);
    
    SAVE_EB_R(j,1)=0;
    SAVE_EB_G(j,1)=0;
    SAVE_EB_B(j,1)=0;
    SAVE_EB_V(j,1)=0;
    SAVE_EB_RP(j,1)=0;
    SAVE_EB_GP(j,1)=0;
    SAVE_EB_BP(j,1)=0;
    SAVE_EB_VP(j,1)=0;
    count_EB_R=zeros(j,2);
    count_EB_G=zeros(j,2);
    count_EB_B=zeros(j,2);
    count_EB_V=zeros(j,2);
    
    for z=1:length(SR_temp)
        
        if(SR_tempP(j,z)=='0')
            SR_P(j,z)=7;
        else
            SR_P(j,z)=7.2;
        end
        if(SG_tempP(j,z)=='0')
            SG_P(j,z)=7.5;
        else
            SG_P(j,z)=7.7;
        end
        if(SB_tempP(j,z)=='0')
            SB_P(j,z)=8;
        else
            SB_P(j,z)=8.2;
        end
        if(SV_tempP(j,z)=='0')
            SV_P(j,z)=8.5;
        else
            SV_P(j,z)=8.7;
        end
        
        if(SR_Parity(j,z)=='0')
            SR_P2(j,z)=7;
        else
            SR_P2(j,z)=7.2;
        end
        if(SG_Parity(j,z)=='0')
            SG_P2(j,z)=7.5;
        else
            SG_P2(j,z)=7.7;
        end
        if(SB_Parity(j,z)=='0')
            SB_P2(j,z)=8;
        else
            SB_P2(j,z)=8.2;
        end
        if(SV_Parity(j,z)=='0')
            SV_P2(j,z)=8.5;
        else
            SV_P2(j,z)=8.7;
        end
        
        if(SR_temp(j,z)=='0')
            if BER_FLAG==1
                if SR_temp(j,z)~=SR_TX(j,z)
                    count_EB_R(j,1)=count_EB_R(j,1)+1;
                    SAVE_EB_R(j,count_EB_R(j,1))= z;
                end
                if SR_tempP(j,z)~=SR_TX(j,z)
                    count_EB_R(j,2)=count_EB_R(j,2)+1;
                    SAVE_EB_RP(j,count_EB_R(j,2))= z;
                end
            end
            SR(j,z)=7;
        else
            if BER_FLAG==1
                if SR_temp(j,z)~=SR_TX(j,z)
                    count_EB_R(j,1)=count_EB_R(j,1)+1;
                    SAVE_EB_R(j,count_EB_R(j,1))= z;
                end
                if SR_tempP(j,z)~=SR_TX(j,z)
                    count_EB_R(j,2)=count_EB_R(j,2)+1;
                    SAVE_EB_RP(j,count_EB_R(j,2))= z;
                end
            end
            SR(j,z)=7.2;
        end
        if(SG_temp(j,z)=='0')
            if BER_FLAG==1
                if SG_temp(j,z)~=SG_TX(j,z)
                    count_EB_G(j,1)=count_EB_G(j,1)+1;
                    SAVE_EB_G(j,count_EB_G(j,1))= z;
                end
                if SG_tempP(j,z)~=SG_TX(j,z)
                    count_EB_G(j,2)=count_EB_G(j,2)+1;
                    SAVE_EB_GP(j,count_EB_G(j,2))= z;
                end
            end
            SG(j,z)=7.5;
        else
            if BER_FLAG==1
                if SG_temp(j,z)~=SG_TX(j,z)
                    count_EB_G(j,1)=count_EB_G(j,1)+1;
                    SAVE_EB_G(j,count_EB_G(j,1))= z;
                end
                if SG_tempP(j,z)~=SG_TX(j,z)
                    count_EB_G(j,2)=count_EB_G(j,2)+1;
                    SAVE_EB_GP(j,count_EB_G(j,2))= z;
                end
            end
            SG(j,z)=7.7;
        end
        if(SB_temp(j,z)=='0')
            if BER_FLAG==1
                if SB_temp(j,z)~=SB_TX(j,z)
                    count_EB_B(j,1)=count_EB_B(j,1)+1;
                    SAVE_EB_B(j,count_EB_B(j,1))= z;
                end
                if SB_tempP(j,z)~=SB_TX(j,z)
                    count_EB_B(j,2)=count_EB_B(j,2)+1;
                    SAVE_EB_BP(j,count_EB_B(j,2))= z;
                end
            end
            SB(j,z)=8;
        else
            if BER_FLAG==1
                if SB_temp(j,z)~=SB_TX(j,z)
                    count_EB_B(j,1)=count_EB_B(j,1)+1;
                    SAVE_EB_B(j,count_EB_B(j,1))= z;
                end
                if SB_tempP(j,z)~=SB_TX(j,z)
                    count_EB_B(j,2)=count_EB_B(j,2)+1;
                    SAVE_EB_BP(j,count_EB_B(j,2))= z;
                end
            end
            SB(j,z)=8.2;
        end
        if(SV_temp(j,z)=='0')
            if BER_FLAG==1
                if SV_temp(j,z)~=SV_TX(j,z)
                    count_EB_V(j,1)=count_EB_V(j,1)+1;
                    SAVE_EB_V(j,count_EB_V(j,1))= z;
                end
                if SV_tempP(j,z)~=SV_TX(j,z)
                    count_EB_V(j,2)=count_EB_V(j,2)+1;
                    SAVE_EB_VP(j,count_EB_V(j,2))= z;
                end
            end
            SV(j,z)=8.5;
        else
            if BER_FLAG==1
                if SV_temp(j,z)~=SV_TX(j,z)
                    count_EB_V(j,1)=count_EB_V(j,1)+1;
                    SAVE_EB_V(j,count_EB_V(j,1))= z;
                end
                if SV_tempP(j,z)~=SV_TX(j,z)
                    count_EB_V(j,2)=count_EB_V(j,2)+1;
                    SAVE_EB_VP(j,count_EB_V(j,2))= z;
                end
            end
            SV(j,z)=8.7;
        end
    end
    
    if BER_FLAG==1
        %BIT ERROR RATE (BER)
        for k=1:2
            EB_R(j,k)=count_EB_R(j,k);
            NB_R(j,k)=length(SR_temp);
            BER_R(j,k)=EB_R(j,k)/NB_R(j,k);
            
            EB_G(j,k)=count_EB_G(j,k);
            NB_G(j,k)=length(SG_temp);
            BER_G(j,k)=EB_G(j,k)/NB_G(j,k);
            
            EB_B(j,k)=count_EB_B(j,k);
            NB_B(j,k)=length(SB_temp);
            BER_B(j,k)=EB_B(j,k)/NB_B(j,k);
            
            EB_V(j,k)=count_EB_V(j,k);
            NB_V(j,k)=length(SV_temp);
            BER_V(j,k)=EB_V(j,k)/NB_V(j,k);
            
            EB_T(j,k)=EB_R(j,k)+EB_G(j,k)+EB_B(j,k)+EB_V(j,k);
            NB_T(j,k)=NB_R(j,k)+NB_G(j,k)+NB_B(j,k)+NB_V(j,k);
            BER_T(j,k)=EB_T(j,k)/NB_T(j,k);
            BER_TT(j,k)=EB_T(j,k)/(NB_T(j,k)*4);
        end
        
        SAVE_EB_R2=SAVE_EB_R(j,:);
        SAVE_EB_G2=SAVE_EB_G(j,:);
        SAVE_EB_B2=SAVE_EB_B(j,:);
        SAVE_EB_V2=SAVE_EB_V(j,:);
        SAVE_EB_R2=SAVE_EB_R2(SAVE_EB_R2~=0);
        SAVE_EB_G2=SAVE_EB_G2(SAVE_EB_G2~=0);
        SAVE_EB_B2=SAVE_EB_B2(SAVE_EB_B2~=0);
        SAVE_EB_V2=SAVE_EB_V2(SAVE_EB_V2~=0);
        
        SAVE_EB_RP2=SAVE_EB_RP(j,:);
        SAVE_EB_GP2=SAVE_EB_GP(j,:);
        SAVE_EB_BP2=SAVE_EB_BP(j,:);
        SAVE_EB_VP2=SAVE_EB_VP(j,:);
        SAVE_EB_RP2=SAVE_EB_RP2(SAVE_EB_RP2~=0);
        SAVE_EB_GP2=SAVE_EB_GP2(SAVE_EB_GP2~=0);
        SAVE_EB_BP2=SAVE_EB_BP2(SAVE_EB_BP2~=0);
        SAVE_EB_VP2=SAVE_EB_VP2(SAVE_EB_VP2~=0);
        
        fprintf('------------------------------------------------------------------------\n');
        fprintf('<strong>                **S/CONTROLO DE ERROS (%s)**</strong>\n', FName1(j,2:15));
        fprintf('------------------------------------------------------------------------\n');
        fprintf('<strong>Rs''</strong>(%s)\n',SR_temp(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_R2),EB_R(j,1));
        fprintf('<strong>BER</strong>(%d)\n',BER_R(j,1));
        fprintf('<strong>-->LED Verde</strong>\n');
        fprintf('<strong>Gs''</strong>(%s)\n',SG_temp(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_G2),EB_G(j,1));
        fprintf('<strong>BER</strong>(%d)\n',BER_G(j,1));
        fprintf('<strong>-->LED Azul</strong>\n');
        fprintf('<strong>Bs''</strong>(%s)\n',SB_temp(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_B2),EB_B(j,1));
        fprintf('<strong>BER</strong>(%d)\n',BER_B(j,1));
        fprintf('<strong>-->LED Violeta</strong>\n');
        fprintf('<strong>Vs''</strong>(%s)\n',SV_temp(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_V2),EB_V(j,1));
        fprintf('<strong>BER</strong>(%d)\n\n',BER_V(j,1));
        fprintf('<strong>NºTotal bits errados</strong>(%d)\n',EB_T(j,1));
        fprintf('<strong>BER Total da FP</strong>(%d) (%d%%)\n',BER_T(j,1), round(BER_T(j,1)*100));
        fprintf('------------------------------------------------\n');
        fprintf('<strong>    **C/CONTROLO DE ERROS (%s)**</strong>\n',FName1(j,2:15));
        fprintf('------------------------------------------------\n');
        fprintf('<strong>-->LED Vermelho</strong>\n');
        fprintf('<strong>Rp</strong>(%s)\n',SR_Parity(j,:));
        fprintf('<strong>Rs</strong>(%s)\n',SR_tempP(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_RP2),EB_R(j,2));
        fprintf('<strong>BER</strong>(%d)\n',BER_R(j,2));
        fprintf('<strong>-->LED Verde</strong>\n');
        fprintf('<strong>Gp</strong>(%s)\n',SG_Parity(j,:));
        fprintf('<strong>Gs</strong>(%s)\n',SG_tempP(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_GP2),EB_G(j,2));
        fprintf('<strong>BER</strong>(%d)\n',BER_G(j,2));
        fprintf('<strong>-->LED Azul</strong>\n');
        fprintf('<strong>Bp</strong>(%s)\n',SB_Parity(j,:));
        fprintf('<strong>Bs</strong>(%s)\n',SB_tempP(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_BP2),EB_B(j,2));
        fprintf('<strong>BER</strong>(%d)\n',BER_B(j,2));
        fprintf('<strong>-->LED Violeta</strong>\n');
        fprintf('<strong>Vp</strong>(%s)\n',SV_Parity(j,:));
        fprintf('<strong>Vs</strong>(%s)\n',SV_tempP(j,:));
        fprintf('<strong>Bits errados</strong>[%s] (%d)\n',num2str(SAVE_EB_VP2),EB_V(j,2));
        fprintf('<strong>BER</strong>(%d)\n\n',BER_V(j,2));
        fprintf('<strong>NºTotal bits errados</strong>(%d)\n',EB_T(j,2));
        fprintf('<strong>BER Total da FP</strong>(%d) (%d%%)\n',BER_T(j,2), round(BER_T(j,2)*100));
        
        fprintf('\n-------------------------------------------------\n');
    end
end
if CC_FLAG==1
    
    %%-----------------------***Representação Gráfica***-----------------------
    figure
    plot(T_STD,y_stairs_STD);
    title({'Curva de Calibração STD com Ganho (Prático)'});
    xlabel('Tempo [ms]');
    ylabel('Intensidade Normalizada');
    xlim([0 2.65])
    ylim([0 1.05])
    hold off;
    %--------------------------------------------------------------------------
    figure
    plot(T_STD,y_stairs_STD);
    hold on
    plot (T_STD,y_stairs_STD_P);
    title({'Curvas de Calibração STD e Paridade (Prático)'});
    xlabel('Tempo [ms]');
    ylabel('Intensidade Normalizada');
    legend({'CC_S_T_D','CC_P'},'Location','Best');
    xlim([0 2.65])
    ylim([0 1.05])
    hold off;
    %--------------------------------------------------------------------------
    figure
    y_stairs_STD_Final_temp(1,:)=y_stairs_STD_Final;
    stairs(T_STD_Final,[y_stairs_STD_Final_temp 1]);
    hold on
    y_stairs_STD_Patiry2_temp(1,:)=y_stairs_STD_Patiry2;
    stairs(T_STD_Patiry2,[y_stairs_STD_Patiry2_temp y_stairs_STD_Patiry2_temp(length(y_stairs_STD_Patiry2_temp))]);
    title({'Curvas de Calibração com 16 Níveis STD (Média)';'e Paridade (Média e Desvio Padrão)'});
    xlabel('Tempo [ms]')
    ylabel('Intensidade Normalizada');
    xline(0.64, 'color', 'k', 'LineStyle', '--' );
    legend({'CC_S_T_D','CC_P'},'Location','Best');
    xlim([0 1.28])
    ylim([0 1.05])
    grid on;
    hold off
    %--------------------------------------------------------------------------
    figure
    y_stairs_STD_Final_temp2(1,:)=y_stairs_STD_Final;
    stairs(T_STD_Final,[y_stairs_STD_Final_temp2 1]);
    hold on
    y_stairs_STD_Patiry_temp2(1,:)=y_stairs_STD_Patiry;
    stairs(T_STD_Patiry,[y_stairs_STD_Patiry_temp2 max(y_stairs_STD_Patiry_temp2)]);
    title({'Curvas de Calibração STD com 16 Níveis (Média)';'e da Paridade com 8 Níveis (Média e Desvio Padrão)'});
    xlabel('Tempo [ms]')
    ylabel('Intensidade Normalizada');
    legend({'CC_S_T_D','CC_P'},'Location','Best');
    xlim([0 1.28])
    ylim([0 1.05])
    grid on;
    hold off
    %--------------------------------------------------------------------------
    figure
    y_stairs_STD_Final_temp2(1,:)=y_stairs_STD_Final;
    y_stairs_STD_Patiry_temp2(1,:)=y_stairs_STD_Patiry;
    for i=1:2:length(STD_Final)
        y_stairs_STD_Final_NP(1,i)= y_stairs_STD_Final_temp2(1,i);
    end
    y_stairs_STD_Final_NP=y_stairs_STD_Final_NP(y_stairs_STD_Final_NP~=0);
    
    stairs(T_STD_Patiry,[0 y_stairs_STD_Final_NP max(y_stairs_STD_Final_NP)]-[y_stairs_STD_Patiry_temp2 max(y_stairs_STD_Patiry_temp2)]);
    yline(0, 'color', 'k', 'LineStyle', '--' );
    
    title({'Desnível entre os 8 Níveis Pares da Curva de Calibração STD';'com os 8 Níveis da Curva de Paridade'});
    xlabel('Tempo [ms]')
    ylabel('Intensidade Normalizada');
    xlim([0 0.64])
    ylim([-0.5 0.5])
    grid on;
    hold off
else
    disp('ATENÇÃO: Gráficos da curva de calibração desactivados!')
end
%--------------------------------------------------------------------------
T_RGBV= (0:(length(SR_temp)))*DeltaT;
Y_text=[11.26 14.30 14.22];
PLUS=[5 2.5 0];
T_Srgbv=TxRx_DATA(1:length(SR_DATA)+1)*10^3;

for i=1:Fname1_y
    
    if BER_FLAG==1
        figure
        subplot(2,1,1);
        stairs(T_Srgbv, PLUS(3)+[SR_DATA(i,:) 7],'r');
        hold on;
        stairs(T_Srgbv, PLUS(3)+[SG_DATA(i,:) 7.5],'g');
        stairs(T_Srgbv, PLUS(3)+[SB_DATA(i,:)  8],'b');
        stairs(T_Srgbv, PLUS(3)+[SV_DATA(i,:) 8.5],'m');
        
        stairs(T_Srgbv, PLUS(2)+[SR_PARITY(i,:) 7],'r');
        stairs(T_Srgbv, PLUS(2)+[SG_PARITY(i,:) 7.5],'g');
        stairs(T_Srgbv, PLUS(2)+[SB_PARITY(i,:)  8],'b');
        stairs(T_Srgbv, PLUS(2)+[SV_PARITY(i,:) 8.5],'m');
        
        xline(T_Srgbv(33), 'color', 'k', 'LineStyle', '--' );
        xline(T_Srgbv(59), 'color', 'k', 'LineStyle', '--');
        xline(T_Srgbv(85), 'color', 'k', 'LineStyle', '--');
        xline(T_Srgbv(111), 'color', 'k', 'LineStyle', '--');
        xline(T_Srgbv(137), 'color', 'k', 'LineStyle', '--');
        xline(T_Srgbv(163), 'color', 'k', 'LineStyle', '--');
        xline(T_Srgbv(189), 'color', 'k', 'LineStyle', '--');
        
        text(T_Srgbv(16), Y_text(1), 'SYNC', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(47), Y_text(1), 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(73), Y_text(1), 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(99), Y_text(1), 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(125), Y_text(1), 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(150), Y_text(1), 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(175), Y_text(1), 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(197), Y_text(1), 'PD', 'HorizontalAlignment', 'center','YLimInclude', 'off');
        
        hold off;
        title({'Sinais Transmitidos Paridade e STD (Prático)';sprintf('%s',FName1(i,2:15));''});
        xlabel('Tempo [ms]');
        set(gca,'YTickLabel',[]);
        xlim([0 2.65])
    end
    
    if BER_FLAG==1
        subplot(2,1,2);
    else
        figure
    end
    
    Norm_MUX_DS3(i,:) = (MUX_DATA(i,:) - min(MUX_DATA(i,:)))/(max(MAX_D2(1,:)) - min(MUX_DATA(i,:)));
    plot(T_Srgbv,[Norm_MUX_DS3(i,:) 0]);
    hold on;
    Norm_MUX_DS3_P(i,:) = (MUX_PARITY(i,:) - min(MUX_PARITY(i,:)))/(max(MAX_D2(1,:)) - min(MUX_PARITY(i,:)));
    plot(T_Srgbv,[Norm_MUX_DS3_P(i,:) 0]);
    
    xline(T_Srgbv(33), 'color', 'k', 'LineStyle', '--' );
    xline(T_Srgbv(59), 'color', 'k', 'LineStyle', '--');
    xline(T_Srgbv(85), 'color', 'k', 'LineStyle', '--');
    xline(T_Srgbv(111), 'color', 'k', 'LineStyle', '--');
    xline(T_Srgbv(137), 'color', 'k', 'LineStyle', '--');
    xline(T_Srgbv(163), 'color', 'k', 'LineStyle', '--');
    xline(T_Srgbv(189), 'color', 'k', 'LineStyle', '--');
    
    if BER_FLAG==1  
        text(T_Srgbv(16), 1.18, 'SYNC', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(47), 1.18, 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(73), 1.18, 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(99), 1.18, 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(125), 1.18, 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(150), 1.18, 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(175), 1.18, 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(197), 1.18, 'PD', 'HorizontalAlignment', 'center','YLimInclude', 'off');
        ylim([0 1.1])
    else
        text(T_Srgbv(16), 1.08, 'SYNC', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(47), 1.08, 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(73), 1.08, 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(99), 1.08, 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(125), 1.08, 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(150), 1.08, 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(175), 1.08, 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
        text(T_Srgbv(197), 1.08, 'PD', 'HorizontalAlignment', 'center','YLimInclude', 'off');
        ylim([0 1.05])
    end
    
    hold off
    title({'Sinais MUX Recebidos STD e Paridade (Prático)';''});
    xlabel('Tempo [ms]');
    ylabel('Intensidade Normalizada');
    legend({'S_S_T_D','S_P'},'Location','Best');
    xlim([0 2.65])
    %--------------------------------------------------------------------------
    figure
    Norm_MUX_DS2=Norm_MUX_DS.';
    Norm_MUX_PS2= Norm_MUX_PS.';
    stairs(T_RGBV,[Norm_MUX_DS2(i,:) 0]);
    hold on;
    stairs(T_RGBV,[Norm_MUX_PS2(i,:) 0]);
    
    xline(T_RGBV(6), 'color', 'k', 'LineStyle', '--' );
    xline(T_RGBV(10), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(14), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(18), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(22), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(26), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(30), 'color', 'k', 'LineStyle', '--');
    
    text(T_RGBV(4), 1.08, ' SYNC  ', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(8), 1.08, 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(12), 1.08, 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(16),1.08, 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(20), 1.08, 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(24), 1.08, 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(28), 1.08, 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(31), 1.08, '    PD', 'HorizontalAlignment', 'center','YLimInclude', 'off');
    
    hold off
    title({'Sinais MUX Recebidos STD e Paridade da';sprintf('%s (Antes da Descodificação)',FName1(i,2:15));''});
    xlabel('Tempo [ms]');
    ylabel('Intensidade Normalizada');
    legend({'S_S_T_D','S_P'},'Location','Best');
    xlim([0 2.56])
    ylim([0 1.05])
    
    figure
    stairs(T_RGBV, PLUS(3)+[SR_P(i,:) 7],'r');
    hold on;
    stairs(T_RGBV, PLUS(3)+[SG_P(i,:) 7.5],'g');
    stairs(T_RGBV, PLUS(3)+[SB_P(i,:) 8],'b');
    stairs(T_RGBV, PLUS(3)+[SV_P(i,:) 8.5],'m');
    
    stairs(T_RGBV, PLUS(2)+[SR(i,:) 7],'r');
    stairs(T_RGBV, PLUS(2)+[SG(i,:) 7.5],'g');
    stairs(T_RGBV, PLUS(2)+[SB(i,:) 8],'b');
    stairs(T_RGBV, PLUS(2)+[SV(i,:) 8.5],'m');
    
    stairs(T_RGBV, PLUS(1)+[SR_P2(i,:) 7],'r');
    stairs(T_RGBV, PLUS(1)+[SG_P2(i,:) 7.5],'g');
    stairs(T_RGBV, PLUS(1)+[SB_P2(i,:) 8],'b');
    stairs(T_RGBV, PLUS(1)+[SV_P2(i,:) 8.5],'m');
    
    xline(T_RGBV(6), 'color', 'k', 'LineStyle', '--' );
    xline(T_RGBV(10), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(14), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(18), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(22), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(26), 'color', 'k', 'LineStyle', '--');
    xline(T_RGBV(30), 'color', 'k', 'LineStyle', '--');
    
    text(T_RGBV(4), Y_text(3), 'SYNC  ', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(8), Y_text(3), 'IDx', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(12), Y_text(3), 'IDy', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(16),Y_text(3), 'IDz', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(20), Y_text(3), 'PIN1', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(24), Y_text(3), 'PIN2', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(28), Y_text(3), 'ANGLE', 'HorizontalAlignment', 'center', 'YLimInclude', 'off');
    text(T_RGBV(31), Y_text(3), '     PD', 'HorizontalAlignment', 'center','YLimInclude', 'off');
    
    hold off;
    title({'Sinais Transmitidos Paridade e STD (s/ e c/Paridade)';sprintf('da %s (Depois da Descodificação)',FName1(i,2:15));''});
    xlabel('Tempo [ms]');
    set(gca,'YTickLabel',[]);
    xlim([0 2.56]) 
end
end