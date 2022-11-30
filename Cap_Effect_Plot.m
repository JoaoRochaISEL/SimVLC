clc; close all; clear all;

filename1 = 'CapEffect.xls';
filename2 = 'CapEffectv2.xls';

%% V1
raw_excel1 = readmatrix(filename1);
Time_OOK = raw_excel1(:,1)'*1000;
R_OOK = raw_excel1(:,2)'-1.75;
OOK = raw_excel1(:,3)';
Time_MAN = raw_excel1(:,4)'*1000;
R_MAN = raw_excel1(:,5)'-1.75;
MAN = raw_excel1(:,6)';

figure('name','Cap Effect V1')
subplot(2,1,1)
stairs(Time_OOK,R_OOK,'r'); axis tight; hold on;
plot(Time_OOK,OOK,'Color','#0072BD'); axis tight; hold on;
xlabel('Time [ms]')
ylim([0 7.75])
title('OOK')
subplot(2,1,2)
plot(Time_MAN,R_MAN,'r'); axis tight; hold on;
plot(Time_MAN,MAN,'Color','#0072BD'); axis tight; hold on;
xlabel('Time [ms]')
ylim([0 7.75])
title('Manchester')

%% V2
raw_excel2 = readmatrix(filename2);
Time_OOK = raw_excel2(:,1)'*1000;
R_OOK = raw_excel2(:,2)'-1.75;
OOK = raw_excel2(:,3)';
Time_MAN = raw_excel2(:,4)'*1000;
R_MAN = raw_excel2(:,5)'-1.75;
MAN = raw_excel2(:,6)';

figure('name','Cap Effect V2')
subplot(2,1,1)
stairs(Time_OOK,R_OOK,'r'); axis tight; hold on;
plot(Time_OOK,OOK,'-o','Color','#0072BD'); axis tight; hold on;
xlabel('Time [ms]')
ylim([0 7.75])
title('OOK')
subplot(2,1,2)
plot(Time_MAN,R_MAN,'r'); axis tight; hold on;
plot(Time_MAN,MAN,'Color','#0072BD'); axis tight; hold on;
xlabel('Time [ms]')
ylim([0 7.75])
title('Manchester')