rind = find(data1.r == 5);
ra = find(tRange == 5);

figure
plot(data1.h,data1.f(:,rind),'LineWidth',2);
hold on
plot(tAlt,m1(:,ra),'-.','LineWidth',2)
grid on
xlabel('Altitude (m)')
ylabel('|F_p| (unitless)')
legend('Baseline','Mean')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([0 30])

figure
plot(tAlt,m1(:,ra),'LineWidth',2)
hold on
temp = [5 15 30];
tind = [1 2 3];

plot(h2,F2a,'LineWidth',2)
% scatter(temp,F2a_10(tind),sz,'filled','bo');
% scatter(temp,F2_10(tind),sz,'filled','ro');
grid on
xlabel('Altitude (m)')
ylabel('|F_p| (unitless)')
legend('TEMPER Mean','Analytic, \pi Phase Shift')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([0 30])