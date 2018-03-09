function plotData(ff,xf,fu,xu,alt, U10, range)

figure
plot(xf,ff,'LineWidth',2)
hold on
plot(xu,fu,'LineWidth',2)
grid on

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

xlabel('Propagation Factor')
ylabel('Probability Density')

legend('Filtered','Unfiltered')
tstring = sprintf('Filtered vs. Unfiltered PDFs, R = %0.0f km, U_{10} = %0.0f mps, H = %0.0f m',range,U10,alt);
title(tstring);