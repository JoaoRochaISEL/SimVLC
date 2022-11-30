 function [L_dB] = Path_Loss(lambda, d_m, k, F_dB, p, W_dB)
 
    %Path_Loss
    % Inputs (por ordem):
    % - d_m = Distância entre emissor e receptor [m];
    % - k = Número de andares atravessados pela onda directa [];
    % - F_dB = Factor de atenuação devido a número de andares [dB];
    % - p = Número de paredes atravessadas pela onda directa [];
    % - W_dB = Factor de atenuação devido às paredes [dB];
    % Output:
    % - L_dB = Atenuação de propagação [dB];
    
    L_dB = 22 + 20*log10(d_m/lambda) + k*F_dB + p*W_dB;
    
 end
