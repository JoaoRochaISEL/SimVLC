function [nWalls] = Material_Counter(Wall_Matrix, p1, p2)

    % Inputs (por ordem):
    % - Wall_Matrix = Matriz com as paredes da planta [];
    % - p1 = Coordenadas da fotodetector [];
    % - p2 = Coordenadas da LED [];
    % - px2d = Distância correspondente por píxel [m];
    %
    % Outputs (por ordem):
    % - nWalls = Número de paredes atravessadas entre o fotodetector e o LED

    old = Wall_Matrix;

    d = p1-p2;                      %%d=p1-p2=[57 134]-[61 134]=[-4 0]
    d = d/max(abs(d));              
    steps = 0:1:max(abs(p2-p1));
    for i = length(p1):-1:1
        p_line(:,i) = round(p2(i) + steps.*d(i));
    end
        
    %Conta as paredes
    nWalls = 0;
    flag = 0;
    
    for i = 1:length(p_line)
    
        y = p_line(i,1);
        x = p_line(i,2);
        
        if(old(y,x)==1) %É o material
            if(flag==0) %Atrás não havia esse material 
                nWalls = nWalls+1;
                flag = 1;
            end
        else %Não é o material
            flag = 0;
        end
    
    end
end