function plotPathStatistics3(tAlt,tRange,varData,meanData,rmsData)

figure
plot(tAlt,varData(1,:,end),'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor Variance')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
plot(tAlt,rmsData(1,:,end),'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor RMS')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
plot(tAlt,meanData(1,:,end),'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor Mean')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

v = varData(1,end,:);
figure
plot(tRange,v(:),'LineWidth',2)
hold on
grid on
xlabel('Downrange (km)')
ylabel('Propagation Factor Variance')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

vr = rmsData(1,end,:);
figure
plot(tRange,vr(:),'LineWidth',2)
hold on
grid on
xlabel('Downrange (km)')
ylabel('Propagation Factor RMS')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

m = meanData(1,end,:);
figure
plot(tRange,m(:),'LineWidth',2)
hold on
grid on
xlabel('Downrange (km)')
ylabel('Propagation Factor Mean')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')


