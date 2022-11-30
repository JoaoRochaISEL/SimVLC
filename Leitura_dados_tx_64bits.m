function Leitura_dados_tx_64bits
clc;
close all;
% --- Leitura de dados TX no excel em 64bits ---

Fname1='B#3C(4,3,1)7261'; %Nome do 1º ficheiro que contem os sinais R1,G1,B1,V1
Fname2='B#1C(4,3,1)7261'; %Nome do 2º ficheiro que contem os sinais R2,G2,B2,V2

data_RGBV = readmatrix('JOAO_R TESTE1 front 21 JULHO.xlsx','Sheet',Fname1);
data2_RGBV = readmatrix('JOAO_R TESTE1 front 21 JULHO.xlsx','Sheet',Fname2);

SR_DATA(:,1) = data_RGBV(129:394,2);
SG_DATA (:,1)= data_RGBV(129:394,3);
SB_DATA(:,1) = data_RGBV(129:394,4);
SV_DATA (:,1)= data_RGBV(129:394,5);

SR_DATA(:,2) = data2_RGBV(129:394,2);
SG_DATA (:,2) = data2_RGBV(129:394,3);
SB_DATA(:,2) = data2_RGBV(129:394,4);
SV_DATA (:,2) = data2_RGBV(129:394,5);

%----Correção de erros do excel----

count=0;
iDel=zeros(1,2);
SR_Right1=SR_DATA(:,1);
SG_Right1=SG_DATA(:,1);
SB_Right1=SB_DATA(:,1);
SV_Right1=SV_DATA(:,1);

SR_Right2=SR_DATA(:,2);
SG_Right2=SG_DATA(:,2);
SB_Right2=SB_DATA(:,2);
SV_Right2=SV_DATA(:,2);

sizeSR_DATA=size(SR_DATA);
SR_DATA_Y=sizeSR_DATA(1);
SR_DATA_X=sizeSR_DATA(2);

for x=1:SR_DATA_X
    
    for i=1:SR_DATA_Y-1
        
        if (SR_DATA(i,x)==SR_DATA(i+1,x) && SG_DATA(i,x)==SG_DATA(i+1,x) && SB_DATA(i,x)==SB_DATA(i+1,x) && SV_DATA(i,x)==SV_DATA(i+1,x))
            count=count+1;
        elseif (x==1 && (SR_DATA(i,x)~=SR_DATA(i+1,x)||SG_DATA(i,x)~=SG_DATA(i+1,x)||SB_DATA(i,x)~=SB_DATA(i+1,x)||SV_DATA(i,x)~=SV_DATA(i+1,x))) && ((count>=4 && mod(count,2) == 0)||count==0)
            
            SR_Right1(i-iDel(1,x))=[];
            SG_Right1(i-iDel(1,x))=[];
            SB_Right1(i-iDel(1,x))=[];
            SV_Right1(i-iDel(1,x))=[];
            
            iDel(1,x)=iDel(1,x)+1;
            count=0;
            iDel_Matrix(x,iDel(1,x))=130+i;
        elseif (x==2 && (SR_DATA(i,x)~=SR_DATA(i+1,x)||SG_DATA(i,x)~=SG_DATA(i+1,x)||SB_DATA(i,x)~=SB_DATA(i+1,x)||SV_DATA(i,x)~=SV_DATA(i+1,x)))&& ((count>=4 && mod(count,2) == 0)||count==0)
            
            SR_Right2(i-iDel(1,x))=[];
            SG_Right2(i-iDel(1,x))=[];
            SB_Right2(i-iDel(1,x))=[];
            SV_Right2(i-iDel(1,x))=[];
            
            iDel(1,x)=iDel(1,x)+1;
            count=0;
            iDel_Matrix(x,iDel(1,x))=130+i;
        else
            count=0;
        end
    end
    count=0;
end


%Correcção de bit errados não detectados
count=0;
if SR_DATA_X==2 && iDel(1,1)<iDel(1,2)
    Dif=iDel(1,2)-iDel(1,1);
    for i=1:length(iDel_Matrix)
        if ((iDel_Matrix(1,i)-iDel_Matrix(2,i))>20 && count<Dif)
            
            SR_Right1(iDel_Matrix(2,i)-i+1-130)=[];
            SG_Right1(iDel_Matrix(2,i)-i+1-130)=[];
            SB_Right1(iDel_Matrix(2,i)-i+1-130)=[];
            SV_Right1(iDel_Matrix(2,i)-i+1-130)=[];
            count=count+1;
            save(1,count)=iDel_Matrix(2,i);
        end
    end
    fprintf('Bit %i errado mas não detectado! \n',save(1,:))
end
if SR_DATA_X==2 && iDel(1,1)>iDel(1,2)
    Dif=iDel(1,1)-iDel(1,2);
    for i=1:length(iDel_Matrix)
        if ((iDel_Matrix(2,i)-iDel_Matrix(1,i))>20 && count<Dif)
            
            SR_Right1(iDel_Matrix(1,i)-i+1-130)=[];
            SG_Right1(iDel_Matrix(1,i)-i+1-130)=[];
            SB_Right1(iDel_Matrix(1,i)-i+1-130)=[];
            SV_Right1(iDel_Matrix(1,i)-i+1-130)=[];
            count=count+1;
            save(1,count)=iDel_Matrix(1,i);
        end
    end
    fprintf('Bit %i errado mas não detectado! \n',save(1,:))
end

SR_temp(1,:)=SR_Right1;
SG_temp(1,:)=SG_Right1;
SB_temp(1,:)=SB_Right1;
SV_temp(1,:)=SV_Right1;

SR_temp(2,:)=SR_Right2;
SG_temp(2,:)=SG_Right2;
SB_temp(2,:)=SB_Right2;
SV_temp(2,:)=SV_Right2;

size_SR=size(SR_temp);
SR_Y=size_SR(1);
SR_X=size_SR(2);

sr_x=0;
sg_x=0;
sb_x=0;
sv_x=0;

countSR=0;
countSG=0;
countSB=0;
countSV=0;
for s_y=1:SR_Y
    for s_x=1:SR_X
        countSR=countSR+1;
        countSG=countSG+1;
        countSB=countSB+1;
        countSV=countSV+1;
        if(SR_temp(s_y,s_x)==7 && countSR==4)
            sr_x=sr_x+1;
            SR(s_y,sr_x)=0;
            countSR=0;
        elseif(SR_temp(s_y,s_x)==7.2 && countSR==4)
            sr_x=sr_x+1;
            SR(s_y,sr_x)=1;
            countSR=0;
        end
        if(SG_temp(s_y,s_x)==7.5 && countSG==4)
            sg_x=sg_x+1;
            SG(s_y,sg_x)=0;
            countSG=0;
        elseif(SG_temp(s_y,s_x)==7.7 && countSG==4)
            sg_x=sg_x+1;
            SG(s_y,sg_x)=1;
            countSG=0;
        end
        if(SB_temp(s_y,s_x)==8 && countSB==4)
            sb_x=sb_x+1;
            SB(s_y,sb_x)=0;
            countSB=0;
        elseif(SB_temp(s_y,s_x)==8.2 && countSB==4)
            sb_x=sb_x+1;
            SB(s_y,sb_x)=1;
            countSB=0;
        end
        if(SV_temp(s_y,s_x)==8.5 && countSV==4)
            sv_x=sv_x+1;
            SV(s_y,sv_x)=0;
            countSV=0;
        elseif(SV_temp(s_y,s_x)==8.7 && countSV==4)
            sv_x=sv_x+1;
            SV(s_y,sv_x)=1;
            countSV=0;
        end
    end
    sr_x=0;
    sg_x=0;
    sb_x=0;
    sv_x=0;
end

fprintf('SR1: [');
fprintf('%d',SR(1,:));
fprintf(']\n')
fprintf('SG1: [');
fprintf('%d',SG(1,:));
fprintf(']\n')
fprintf('SB1: [');
fprintf('%d',SB(1,:));
fprintf(']\n')
fprintf('SV1: [');
fprintf('%d',SV(1,:));
fprintf(']\n\n')

fprintf('SR2: [');
fprintf('%d',SR(2,:));
fprintf(']\n')
fprintf('SG2: [');
fprintf('%d',SG(2,:));
fprintf(']\n')
fprintf('SB2: [');
fprintf('%d',SB(2,:));
fprintf(']\n')
fprintf('SV2: [');
fprintf('%d',SV(2,:));
fprintf(']\n')
end