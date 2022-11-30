function h = Circle(x,y,r,n)
    
    th = 0:pi/100:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    if(n==1)
        h = plot(xunit, yunit,'r','LineWidth',2);
    elseif(n==2)
        h = plot(xunit, yunit,'g','LineWidth',2);
    elseif(n==3)
        h = plot(xunit, yunit,'b','LineWidth',2);
    else
        h = plot(xunit, yunit,'m','LineWidth',2);
    end
    
end




