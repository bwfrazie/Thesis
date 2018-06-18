function plotTdata(tdata)
 
figure
% subplot(1,2,1)

imagesc(tdata.h,tdata.r,tdata.fdb);
grid on
xlabel('Range (km)')
ylabel('Altitude (m)')

set(gca,'YDir','normal')
colormap(jet(256))
colorbar
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
title('Propagation Factors (dB)')
xlim([0 50])
caxis([-80 3])
% axis square

% subplot(1,2,2)
figure
rind10 = find(tdata.r == 10);
rind15 = find(tdata.r == 15);
rind20 = find(tdata.r == 20);

plot(tdata.h,tdata.f(:,rind10),'LineWidth',2);
hold on
plot(tdata.h,tdata.f(:,rind15),'--','LineWidth',2);
plot(tdata.h,tdata.f(:,rind20),'-.','LineWidth',2);
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('Altitude (m)')
ylabel('Propagation Factor')
legend('10km','15km','20km','Location','Southeast')
xlim([0 30])
ylim([0 2])
grid on

figure
aind5 = find(abs(tdata.h - 5) < 0.025);
aind10 = find(abs(tdata.h - 10) < 0.025);
aind20 = find(abs(tdata.h - 20) < 0.025);
aind30 = find(abs(tdata.h - 30) < 0.025);
plot(tdata.r,tdata.f(aind5,:),'LineWidth',2);
hold on
plot(tdata.r,tdata.f(aind10,:),'--','LineWidth',2);
plot(tdata.r,tdata.f(aind20,:),'-.','LineWidth',2);
plot(tdata.r,tdata.f(aind30,:),'-.','LineWidth',2);
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('Range (km)')
ylabel('Propagation Factor')
legend('5m','10m','20m','30m','Location','Southeast')
xlim([0 30])
ylim([0 2])
grid on