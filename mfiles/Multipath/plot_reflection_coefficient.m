function plot_reflection_coefficient

f = 35e9;
lambda = 3e8/f;

%first look at rho vs RMS sea height
sigma = linspace(0.01,10,1000);
graz = [0.1 0.2 0.5 1] * pi/180;

rho = [];
for counter = 1:length(graz)
    reflection = getReflectionCoefficient(graz(counter),sigma,lambda);
    rho = [rho reflection'];
end

figure
semilogx(sigma,20*log10(abs(rho)),'LineWidth',2);
xlabel('RMS Wave Height (m)')
ylabel('R(dB)')
grid on
ylim([-30 0])
xlim([sigma(1) sigma(end)])
l1 = sprintf('%0.1f deg',graz(1)*180/pi);
l2 = sprintf('%0.1f deg',graz(2)*180/pi);
l3 = sprintf('%0.1f deg',graz(3)*180/pi);
l4 = sprintf('%0.1f deg',graz(4)*180/pi);
legend(l1,l2,l3,l4);
title('Reflection Coefficient vs. RMS Wave Height')
tstring = sprintf('f: %0.1f GHz',f/1e9);
text(sigma(1)+0.001,-25,tstring);
text(sigma(1)+0.001,-26,'Parameter: Grazing Angle');

set(gca,'LineWidth',2);
set(gca,'FontSize',12);
set(gca,'FontWeight','Bold');

%now look at rho vs grazing angle
graz1 = linspace(0.1,10,1000);
graz1 = graz1*pi/180;
sigma1 = [0.01 0.1 0.5 1];

rho = [];
for counter = 1:length(sigma1)
    reflection = getReflectionCoefficient(graz1,sigma1(counter),lambda);
    rho = [rho reflection'];
end

figure
plot(graz1*180/pi,20*log10(abs(rho)),'LineWidth',2);
xlabel('Grazing Angle (deg)')
ylabel('R (dB)')
grid on
ylim([-30 0])
% xlim([graz1(1)*180/pi graz1(end)*180/pi])
l1 = sprintf('%0.2f m',sigma1(1));
l2 = sprintf('%0.2f m',sigma1(2));
l3 = sprintf('%0.2f m',sigma1(3));
l4 = sprintf('%0.2f m',sigma1(4));
legend(l1,l2,l3,l4);
title('Reflection Coefficient vs. Grazing Angle')
tstring = sprintf('f: %0.1f GHz',f/1e9);
text(graz1(1)+0.25,-25,tstring);
text(graz1(1)+0.25,-26,'Parameter: RMS Wave Height');

set(gca,'LineWidth',2);
set(gca,'FontSize',12);
set(gca,'FontWeight','Bold');