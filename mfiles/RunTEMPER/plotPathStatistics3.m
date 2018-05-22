function plotPathStatistics3(tAlt,tRange,varData,meanData,rmsData)

figure
plot(tAlt,varData(1,:,end),'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor Variance')
% plot(tAlt,varData(2,:,end),'LineWidth',2)
legend('10 mps','5 mps')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
plot(tAlt,rmsData(1,:,end).^2,'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor Variance No Mean')
% plot(tAlt,rmsData(2,:,end).^2,'LineWidth',2)
legend('10 mps','5 mps')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
plot(tAlt,meanData(1,:,end),'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor Mean')
% plot(tAlt,meanData(2,:,end),'LineWidth',2)
legend('10 mps','5 mps')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

