clc; close all; clear all;

imported_excel = 'C:\Users\joaom\Dropbox\TFM\Scenarios\Best Measurements V5 (round)\Scenario2t0.xls';
raw_excel_OOK = readmatrix(imported_excel,'Sheet','OOK');
raw_excel_MAN = readmatrix(imported_excel,'Sheet','MAN');

%OOK:
Time_OOK = raw_excel_OOK(:,1)'*1000;
R_OOK = raw_excel_OOK(:,2)';
G_OOK = raw_excel_OOK(:,3)';
B_OOK = raw_excel_OOK(:,4)';
V_OOK = raw_excel_OOK(:,5)';
MUX_OOK = raw_excel_OOK(:,6)';
%parity_OOK = raw_excel(:,7)';
figure('name','Raw Measurements - OOK')
subplot(3,1,1)
stairs(Time_OOK,R_OOK,'r','LineWidth',1.5); axis tight; hold on;
stairs(Time_OOK,G_OOK,'g','LineWidth',1.5); axis tight; hold on;
stairs(Time_OOK,B_OOK,'b','LineWidth',1.5); axis tight; hold on;
stairs(Time_OOK,V_OOK,'m','LineWidth',1.5); axis tight; hold on;
ylim([6 8.5+1])
xlim([4.7 5.25])
xlabel('Time [ms]')
ylabel('Emitted Signals (LEDs)')
yticks([6.25:0.5:7.75])
yticklabels({'V','B','G','R'})
offset = 0.03/2;
text(4.75+0.045-offset,8.6,'ON');
text(4.835+0.045-offset,8.6,'OFF');
text(4.915+0.045-offset,8.6,'ON');
text(5+0.045-offset,8.6,'OFF');
text(5.08+0.045-offset,8.6,'ON');
subplot(3,1,[2 3])
plot(Time_OOK,MUX_OOK,'LineWidth',1.5); axis tight; hold on;
ylim([0 6])
xlim([4.7 5.25])
xlabel('Time [ms]')
ylabel('Received Signal (Photodiode)')
%legend('MUX','R','G','B','V','Location','north','NumColumns',5);
%set(gca,'FontSize',15);
for i = [4.75 4.835 4.915 5 5.08 5.165]
    subplot(3,1,1)
    xline(i,'--');
    subplot(3,1,[2 3])
    xline(i,'--');
end
offset = 0.03/2;
text(4.75+0.045-offset,5.3,'ON');
text(4.835+0.045-offset,5.3,'OFF');
text(4.915+0.045-offset,5.3,'ON');
text(5+0.045-offset,5.3,'OFF');
text(5.08+0.045-offset,5.3,'ON');

%MANCHESTER:
Time_MAN = raw_excel_MAN(:,1)'*1000;
R_MAN = raw_excel_MAN(:,2)';
G_MAN = raw_excel_MAN(:,3)';
B_MAN = raw_excel_MAN(:,4)';
V_MAN = raw_excel_MAN(:,5)';
MUX_MAN = raw_excel_MAN(:,6)';
%parity_MAN = raw_excel(:,7)';
figure('name','Raw Measurements - Manchester')
subplot(3,1,1)
stairs(Time_MAN,R_MAN,'r','LineWidth',1.5); axis tight; hold on;
stairs(Time_MAN,G_MAN,'g','LineWidth',1.5); axis tight; hold on;
stairs(Time_MAN,B_MAN,'b','LineWidth',1.5); axis tight; hold on;
stairs(Time_MAN,V_MAN,'m','LineWidth',1.5); axis tight; hold on;
ylim([6 8.5+1])
xlim([4.615 5.6])
xlabel('Time [ms]')
ylabel('Emitted Signals (LEDs)')
yticks([6.25:0.5:7.75])
yticklabels({'V','B','G','R'})
offset = 0.03;
text(4.835-offset,8.6,'ON');
text(5-offset,8.6,'OFF');
text(5.165-offset,8.6,'ON');
text(5.33-offset,8.6,'OFF');
text(5.495-offset,8.6,'ON');
subplot(3,1,[2 3])
plot(Time_MAN,MUX_MAN,'LineWidth',1.5); axis tight; hold on;
ylim([0 6])
xlim([4.615 5.6])
%xlim([951 3075])
xlabel('Time [ms]')
ylabel('Received Signal (Photodiode)')
%legend('MUX','R','G','B','V','Location','north','NumColumns',5);
%set(gca,'FontSize',15);
for i = [4.665 4.835 5 5.165 5.33 5.495]+0.08
    subplot(3,1,1)
    xline(i,'--');
    subplot(3,1,[2 3])
    xline(i,'--');
end
offset = 0.03;
text(4.835-offset,5.3,'ON');
text(5-offset,5.3,'OFF');
text(5.165-offset,5.3,'ON');
text(5.33-offset,5.3,'OFF');
text(5.495-offset,5.3,'ON');