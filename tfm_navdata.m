function [] = tfm_navdata(received)

    %tfm_navdata - Converte os bits recebidos em informação de navegação
    %[] = tfm_navdata(received)
    %
    % Inputs (por ordem):
    % - received = bits recebidos em estructura (.R,.G,.B,.V)
    %
    % Output:
    % - <None> (Apareçe na command window)
    
    %Passa de bits em informação fácil de perceber
    R = received.R;
    G = received.G;
    B = received.B;
    V = received.V;
    
    %disp('------------------ Decoded Simulated Transmission ------------------')
    
    %HEADER
    vlc_header = zeros(1,5);
    for i = 1:5
        vlc_header(i) = bi2de([V(i) B(i) G(i) R(i)]);
    end
    footprint = round(mean(vlc_header([1 3 5])));
    switch footprint
        case 15
            footprint = 1;
        case 14
            footprint = 2;
        case 13
            footprint = 8;
        case 12
            footprint = 9;
        case 11
            footprint = 4;
        case 10
            footprint = 3;
        case 7
            footprint = 6;
        case 5
            footprint = 7;
        case 3
            footprint = 5;
    end
    disp(['Synch = ',num2str(vlc_header)]);
    disp(['Footprint = #',num2str(footprint)])
    
    %CALIBRATION
    vlc_calibration = zeros(1,32);
    ii = 1;
    for i = 6:37
        vlc_calibration(ii) = bi2de([V(i) B(i) G(i) R(i)]);
        ii = ii+1;
    end
    %disp(['Calibration Curve = ',num2str(vlc_calibration)]);
    
    %X
    vlc_x = zeros(1,4);
    vlc_x(1) = bi2de([R(41) R(40) R(39) R(38)]);
    vlc_x(2) = bi2de([G(41) G(40) G(39) G(38)]);
    vlc_x(3) = bi2de([B(41) B(40) B(39) B(38)]);
    vlc_x(4) = bi2de([V(41) V(40) V(39) V(38)]);
    %disp(['X = ',num2str(vlc_x)]);
    
    %Y
    vlc_y = zeros(1,4);
    vlc_y(1) = bi2de([R(45) R(44) R(43) R(42)]);
    vlc_y(2) = bi2de([G(45) G(44) G(43) G(42)]);
    vlc_y(3) = bi2de([B(45) B(44) B(43) B(42)]);
    vlc_y(4) = bi2de([V(45) V(44) V(43) V(42)]);
    %disp(['Y = ',num2str(vlc_y)]);
    
    %Z
%     vlc_z = zeros(1,4);
%     vlc_z(1) = bi2de([R(49) R(48) R(47) R(46)]);
%     vlc_z(2) = bi2de([G(49) G(48) G(47) G(46)]);
%     vlc_z(3) = bi2de([B(49) B(48) B(47) B(46)]);
%     vlc_z(4) = bi2de([V(49) V(48) V(47) V(46)]);
%     vlc_z(1) = (-1*R(46))*bi2de([R(49) R(48) R(47)]);
%     vlc_z(2) = (-1*G(46))*bi2de([G(49) G(48) G(47)]);
%     vlc_z(3) = (-1*B(46))*bi2de([B(49) B(48) B(47)]);
%     vlc_z(4) = (-1*V(46))*bi2de([V(49) V(48) V(47)]);
    %disp(['Z = ',num2str(vlc_z)]);
    %Z NEW ATTEMPT:
    vlc_z1 = round(mean([R(46) G(46) B(46) V(46)]));
    vlc_z2 = round(mean([R(49) G(49) B(49) V(49)]));
    vlc_z3 = round(mean([R(48) G(48) B(48) V(48)]));
    vlc_z4 = round(mean([R(47) G(47) B(47) V(47)]));
    if ~vlc_z1
        vlc_z = bi2de([vlc_z2 vlc_z3 vlc_z4]);
    else
        vlc_z = (-1*vlc_z1)*bi2de([vlc_z2 vlc_z3 vlc_z4]);
    end
    
    %ID (x, y, z)
%     disp(['ID: R_',num2str(vlc_y(1)),',',num2str(vlc_x(1)),',',num2str(vlc_z(1))]);
%     disp(['ID: G_',num2str(vlc_y(2)),',',num2str(vlc_x(2)),',',num2str(vlc_z(2))]);
%     disp(['ID: B_',num2str(vlc_y(3)),',',num2str(vlc_x(3)),',',num2str(vlc_z(3))]);
%     disp(['ID: V_',num2str(vlc_y(4)),',',num2str(vlc_x(4)),',',num2str(vlc_z(4))]);
    disp(['ID: R_',num2str(vlc_x(1)),',',num2str(vlc_y(1)),',',num2str(vlc_z)]);
    disp(['ID: G_',num2str(vlc_x(2)),',',num2str(vlc_y(2)),',',num2str(vlc_z)]);
    disp(['ID: B_',num2str(vlc_x(3)),',',num2str(vlc_y(3)),',',num2str(vlc_z)]);
    disp(['ID: V_',num2str(vlc_x(4)),',',num2str(vlc_y(4)),',',num2str(vlc_z)]);
    
    %PIN1
    vlc_pin1 = zeros(1,4);
    vlc_pin1(1)=bi2de([R(53) R(52) R(51) R(50)]);%R
    vlc_pin1(2)=bi2de([G(53) G(52) G(51) G(50)]);%G
    vlc_pin1(3)=bi2de([B(53) B(52) B(51) B(50)]);%B
    vlc_pin1(4)=bi2de([V(53) V(52) V(51) V(50)]);%V
    pin1 = vlc_pin1(1)*1000+vlc_pin1(2)*100+vlc_pin1(3)*10+vlc_pin1(4);
    %disp(['Pin1 = ',num2str(vlc_pin1)]);
    disp(['Pin1 = ',num2str(pin1)]);
    
    %PIN2
    vlc_pin2 = zeros(1,4);
    vlc_pin2(1)=bi2de([R(57) R(56) R(55) R(54)]);%R
    vlc_pin2(2)=bi2de([G(57) G(56) G(55) G(54)]);%G
    vlc_pin2(3)=bi2de([B(57) B(56) B(55) B(54)]);%B
    vlc_pin2(4)=bi2de([V(57) V(56) V(55) V(54)]);%V
    pin2 = vlc_pin2(1)*1000+vlc_pin2(2)*100+vlc_pin2(3)*10+vlc_pin2(4);
    %disp(['Pin2 = ',num2str(vlc_pin2)]);
    disp(['Pin2 = ',num2str(pin2)]);
    
    %STEERING ANGLE
    vlc_angle = zeros(1,4);
    ii = 1;
    for i = 58:61
        vlc_angle(ii) = bi2de([V(i) B(i) G(i) R(i)]);
        ii = ii+1;
    end
    vlc_angle = round(vlc_angle./15);
    vlc_angle = bi2de(fliplr(vlc_angle));
    vlc_angle_code = vlc_angle;
    switch vlc_angle
        case 2
            vlc_angle = 'SE';
        case 3
            vlc_angle = 'E';
        case 4
            vlc_angle = 'NE';
        case 5
            vlc_angle = 'N';
        case 6
            vlc_angle = 'NW';
        case 7
            vlc_angle = 'W';
        case 8
            vlc_angle = 'SW';
        case 9
            vlc_angle = 'S';
        otherwise
            vlc_angle = 'None';
    end
    disp(['Angle = ',num2str(vlc_angle_code),' (',vlc_angle,')']);
    
    %PAYLOAD
    vlc_payload = zeros(1,3);
    ii = 1;
    for i = 62:64
        vlc_payload(ii) = bi2de([V(i) B(i) G(i) R(i)]);
        ii = ii+1;
    end
    disp(['Payload = ',num2str(vlc_payload)]);
    
end