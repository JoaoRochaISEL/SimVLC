function [Indoor_Matrix] = Indoor_Finder(RGB)

    % Indoor_Finder - Determina as partes da planta que vai simular
    %
    % Inputs (por ordem):
    % - RGB = Código RGB da planta [];
    %
    % Output:
    % - Indoor_Matrix = Matrix com parte indoor da planta
    %       (0 = Outdoor)
    %       (1 = Indoor)

    Indoor_Matrix = ((RGB.R~=195).*(RGB.G~=195).*(RGB.B~=195));

end