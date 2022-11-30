 function [L_dB] = Path_Loss(lambda, d_m, k, F_dB, p, W_dB)
 
    %Path_Loss
    % Inputs (por ordem):
    % - d_m = Dist�ncia entre emissor e receptor [m];
    % - k = N�mero de andares atravessados pela onda directa [];
    % - F_dB = Factor de atenua��o devido a n�mero de andares [dB];
    % - p = N�mero de paredes atravessadas pela onda directa [];
    % - W_dB = Factor de atenua��o devido �s paredes [dB];
    % Output:
    % - L_dB = Atenua��o de propaga��o [dB];
    
    L_dB = 22 + 20*log10(d_m/lambda) + k*F_dB + p*W_dB;
    
 end
