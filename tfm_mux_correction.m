function [mux_corrigido] = tfm_mux_correction(somatorio,capacitive_samples)
    
    %ESTE É FEITO PARA O SINAL DO MUX
    
    %Workaround (Not sure if good idea...)
    mux_corrigido = zeros(1,length(somatorio)/capacitive_samples);
    
    %mux_corrigido = zeros(1,length(somatorio)/capacitive_samples);
    idx = 1;
    for mux_bit = 1:capacitive_samples:length(somatorio)
        mux_samples = somatorio(mux_bit:mux_bit+capacitive_samples-1);
        mux_last_sample = somatorio(mux_bit+capacitive_samples-1);
        mux_corrigido(idx) = round(mux_last_sample);
        idx = idx+1;
    end
    
end
