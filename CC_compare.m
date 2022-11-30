clc; close all; clear all;
%% FIG IMPORTING

fig = openfig('cc_none.fig','invisible');
fig = gcf;
%ax = get(fig,'children') 
% % get handles to the elements in the axes: a single line plot here
%h = get(ax,'children') 
% % manipulate desired properties of the line, e.g. line width
%set(h,'LineWidth',3)
axObjs = fig.Children;
dataObjs = axObjs.Children;
ook_none.x = dataObjs(1).XData;
ook_none.y = dataObjs(1).YData;

% fig = gcf % get a handle to the current figure
% % get handles to the children of that figure: the axes in this case
% ax = get(fig,'children') 
% % get handles to the elements in the axes: a single line plot here
% h = get(ax,'children') 
% % manipulate desired properties of the line, e.g. line width
% set(h,'LineWidth',3)

fig = openfig('cc_halogen.fig','invisible');
fig = gcf;
axObjs = fig.Children;
dataObjs = axObjs.Children;
ook_halogen.x = dataObjs(1).XData;
ook_halogen.y = dataObjs(1).YData;

fig = openfig('cc_fluorescent.fig','invisible');
fig = gcf;
axObjs = fig.Children;
dataObjs = axObjs.Children;
ook_fluorescent.x = dataObjs(1).XData;
ook_fluorescent.y = dataObjs(1).YData;

fig = openfig('cc_led.fig','invisible');
fig = gcf;
axObjs = fig.Children;
dataObjs = axObjs.Children;
ook_led.x = dataObjs(1).XData;
ook_led.y = dataObjs(1).YData;

%% PLOTS

close all

figure('name','CC Comparison')
stairs(ook_none.x,ook_none.y,'LineWidth',2); hold on;
stairs(ook_halogen.x,ook_halogen.y,'LineWidth',2); hold on;
stairs(ook_fluorescent.x,ook_fluorescent.y,'LineWidth',2); hold on;
stairs(ook_led.x,ook_led.y,'LineWidth',2); hold on;
legend('None','Halogen Lamp','Ceiling Light','LED Light','Location','Best');
%title('OOK-RZ')
xlim([ook_led.x(1) ook_led.x(end)])
xticks([0.04:0.08: 1.24])
xticklabels({'-','V','B','BV','G','GV','GB','GBV',...
            'R','RV','RB','RBV','RG','RGV','RGB','RGBV'})
yticks([linspace(0,1,16)]);% grid on;
yticklabels({'0000','0001','0010','0011','0100','0101','0110','0111',...
            '1000','1001','1010','1011','1100','1101','1110','1111'})
set(gca,'YGrid','on')

figure('name','CC Comparison (Bar Graph)')
barras = [ook_none.y; ook_halogen.y; ook_fluorescent.y; ook_led.y];
%bar(ook_none.x,barras)
bar([0:16],barras)
xlim([0 15.5])
ylim([0 1.01])
legend('None','Halogen Lamp','Fluorescent Light','LED Light','Location','NorthWest');
xticks([0:16])
yticks([linspace(0,1,16)]);% grid on;
yticklabels({'0000','0001','0010','0011','0100','0101','0110','0111',...
            '1000','1001','1010','1011','1100','1101','1110','1111'})
xticklabels({'-','V','B','BV','G','GV','GB','GBV',...
            'R','RV','RB','RBV','RG','RGV','RGB','RGBV'})
set(gca,'YGrid','on')

figure('name','Bar Difference from What Expected')
esperado = linspace(0,1,16);
none_difference = ook_none.y(1:16)-esperado;
halogen_difference = ook_halogen.y(1:16)-esperado;
fluorescent_difference = ook_fluorescent.y(1:16)-esperado;
led_difference = ook_led.y(1:16)-esperado;
barras2 = [none_difference; halogen_difference; fluorescent_difference; led_difference];
%bar([0:15],barras2)
bar([0:15],barras2,'stacked')
legend('None','Halogen Lamp','Fluorescent Light','LED Light','Location','NorthWest','NumColumns',2);
xticks([0:16])
xlim([-0.5 15.5])

figure('name','Mean Difference from What Expected')
bar([mean(none_difference) mean(halogen_difference) mean(fluorescent_difference) mean(led_difference)])
xticklabels({'None','Halogen Lamp','Fluorescent Light','LED Light'})
ylabel('Mean difference')

figure('name','Bar Difference from None')
none = ook_none.y(1:16);
none_halogen_difference = ook_halogen.y(1:16)-none;
none_fluorescent_difference = ook_fluorescent.y(1:16)-none;
none_led_difference = ook_led.y(1:16)-none;
barras3 = [none_halogen_difference; none_fluorescent_difference; none_led_difference];
bar([0:15],barras3,'stacked')
ylim([-0.06 0.08])
legend('Halogen Lamp','Fluorescent Light','LED Light','Location','North','NumColumns',3);
xticks([0:16])
xlim([-0.5 15.5])

figure('name','Bar Difference from None (In Percentage)')%ESTE NÃO ESTÁ BEM!
none = ook_none.y(1:16);
none_halogen_difference = ook_halogen.y(1:16)-none;
none_fluorescent_difference = ook_fluorescent.y(1:16)-none;
none_led_difference = ook_led.y(1:16)-none;
percent_halogen = (none_halogen_difference*100)./none;
percent_fluorescent = (none_fluorescent_difference*100)./none;
percent_led = (none_led_difference*100)./none;
barras3 = [percent_halogen; percent_fluorescent; percent_led];
bar([0:15],barras3,'stacked')
%ylim([-0.06 0.08])
legend('Halogen Lamp','Fluorescent Light','LED Light','Location','North','NumColumns',3);
xticks([0:16])
xlim([-0.5 15.5])