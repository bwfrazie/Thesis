% function plotTdata(tdata)
 
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
xlim([5 25])
caxis([-10 0])
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
% axis square