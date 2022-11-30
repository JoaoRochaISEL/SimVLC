function Ganho_tx=GanhoTx(dx,d,In_dBm,teta3db)

     FOV=deg2rad(120);                       %120
     m=-log(2)/(log(cos(teta3db)));          %=1
     A=8.96*10^-6;                           %[m^2]
     teta=asin(dx/d);
     fi=teta;
     
     In_linear_w=10.^(In_dBm/10)/1000;
     In_lm=90*In_linear_w;
     In_cd=In_lm/(2*pi*(1-cos(teta3db)));
     
      if(teta>FOV)
         Ganho_tx=10*log10(0.001);
      else
        Ganho_tx_linear=(((m+1)*A)/(2*pi*d^2))*In_cd*(cos(fi)^m)*(cos(teta));
        Ganho_tx=10*log10(Ganho_tx_linear);
      end
end
