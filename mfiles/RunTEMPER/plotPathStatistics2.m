function plotPathStatistics2(tData,varData,meanData)

lw = 3;
fs = 28;

figure
subplot(2,1,2)
plot(tData.tAlt,sqrt(varData(1,:,end)),'LineWidth',lw)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Std Deviation (m) ')
plot(tData.tAlt,sqrt(varData(2,:,end)),'LineWidth',lw)
plot(tData.tAlt,sqrt(varData(3,:,end)),'LineWidth',lw)
plot(tData.tAlt,sqrt(varData(4,:,end)),'LineWidth',lw)
plot(tData.tAlt,sqrt(varData(5,:,end)),'LineWidth',lw)
% legend('Unfiltered','10.5dB','6dB','3dB','1.2dB');
set(gca,'LineWidth',2)
set(gca,'FontSize',fs)
set(gca,'FontWeight','bold')
title('Propagation Factor Std Deviation')

subplot(2,1,1)
plot(tData.tAlt,abs(meanData(1,:,end)),'LineWidth',lw)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Mean (m)')
plot(tData.tAlt,abs(meanData(2,:,end)),'LineWidth',lw)
plot(tData.tAlt,abs(meanData(3,:,end)),'LineWidth',lw)
plot(tData.tAlt,abs(meanData(4,:,end)),'LineWidth',lw)
plot(tData.tAlt,abs(meanData(5,:,end)),'LineWidth',lw)
% legend('Unfiltered','10.5dB','6dB','3dB','1.2dB');
set(gca,'LineWidth',2)
set(gca,'FontSize',fs)
set(gca,'FontWeight','bold')
title('Mean Propagation Factors')

aind = find(abs(tData.tAlt - 10)<=0.025);
figure
subplot(2,1,2)
plot(tData.tRange,reshape(sqrt(varData(1,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
hold on
grid on
xlabel('Range (km)')
ylabel('Std Deviation (m)')
plot(tData.tRange,reshape(sqrt(varData(2,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
plot(tData.tRange,reshape(sqrt(varData(3,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
plot(tData.tRange,reshape(sqrt(varData(4,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
plot(tData.tRange,reshape(sqrt(varData(5,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
% legend('Unfiltered','10.5dB','6dB','3dB','1.2dB');
set(gca,'LineWidth',2)
set(gca,'FontSize',fs)
set(gca,'FontWeight','bold')
title('Propagation Factor Std Deviation')
xlim([10 20])

subplot(2,1,1)
plot(tData.tRange,reshape(abs(meanData(1,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
hold on
grid on
xlabel('Range (km)')
ylabel('Mean (m)')
plot(tData.tRange,reshape(abs(meanData(2,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
plot(tData.tRange,reshape(abs(meanData(3,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
plot(tData.tRange,reshape(abs(meanData(4,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
plot(tData.tRange,reshape(abs(meanData(5,aind,:)),[1 length(tData.tRange)]),'LineWidth',lw)
% legend('Unfiltered','10.5dB','6dB','3dB','1.2dB');
set(gca,'LineWidth',2)
set(gca,'FontSize',fs)
set(gca,'FontWeight','bold')
title('Mean Propagation Factors')
xlim([10 20])