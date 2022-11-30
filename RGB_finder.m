function [found_Matrix] = RGB_finder(RGB,R,G,B)

    % Inputs (por ordem):
    % - RGB = C�digo RGB da planta [];
    % - R = C�digo RGB da cor vermelha do que se pretende encontrar [];
    % - G = C�digo RGB da cor verde do que se pretende encontrar [];
    % - B = C�digo RGB da cor azul do que se pretende encontrar [];
    %
    % Output:
    % - found_Matrix = Matrix com o que foi encontrado
    %       (0 = N�o est� l� o material)
    %       (1 = Est� l� o material)
    
    found_Matrix = ((RGB.R==R).*(RGB.G==G).*(RGB.B==B));

end

