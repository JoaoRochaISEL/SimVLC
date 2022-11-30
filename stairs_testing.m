clc; close all; clear all;

x=[1 0 1 1 0 1 0 0 1];

figure('name','Stairs Testing')
stairs([1:length(x)],x,'LineWidth',1.5)
xticks([1:length(x)]+0.5)
set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9'})