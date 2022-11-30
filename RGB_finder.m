function [found_Matrix] = RGB_finder(RGB,R,G,B)

    % Inputs (por ordem):
    % - RGB = Código RGB da planta [];
    % - R = Código RGB da cor vermelha do que se pretende encontrar [];
    % - G = Código RGB da cor verde do que se pretende encontrar [];
    % - B = Código RGB da cor azul do que se pretende encontrar [];
    %
    % Output:
    % - found_Matrix = Matrix com o que foi encontrado
    %       (0 = Não está lá o material)
    %       (1 = Está lá o material)
    
    found_Matrix = ((RGB.R==R).*(RGB.G==G).*(RGB.B==B));

end

