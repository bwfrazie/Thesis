%function plotSwerlingPDFs
function plotSwerlingPDFs

x = linspace(0,20,1000);
y1 = chi2pdf(x,2);
y3 = chi2pdf(x,4);

figure
plot(x,y1,'LineWidth',2);
hold on
plot(x,y3,'LineWidth',2);
grid on
xlabel('RCS (dBsm)')
ylabel('Probability')
title('Fluctuating Target PDFs')
legend('Swerling Case 1/2','Swerling Case 3/4')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
