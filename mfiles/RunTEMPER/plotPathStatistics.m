function plotPathStatistics(tData,varData,meanData)

figure
plot(tData.tAlt,varData(1,:,end),'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor Variance')
plot(tData.tAlt,varData(2,:,end),'LineWidth',2)
plot(tData.tAlt,varData(3,:,end),'LineWidth',2)
plot(tData.tAlt,varData(4,:,end),'LineWidth',2)
plot(tData.tAlt,varData(5,:,end),'LineWidth',2)
plot(tData.tAlt,varData(6,:,end),'LineWidth',2)
legend('Unfiltered','.25 2-Way','.50 2-Way','.75 2-Way','.25 1-Way','.50 1-Way');
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
%plot(data.h,data.f(:,rInd),'LineWidth',2)
plot(tData.tAlt,meanData(1,:,end),'LineWidth',2)
hold on
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor Mean Value')
%plot(tData.tAlt,meanData(1,:,end),'LineWidth',2)
plot(tData.tAlt,meanData(2,:,end),'LineWidth',2)
plot(tData.tAlt,meanData(3,:,end),'LineWidth',2)
plot(tData.tAlt,meanData(4,:,end),'LineWidth',2)
plot(tData.tAlt,meanData(5,:,end),'LineWidth',2)
plot(tData.tAlt,meanData(6,:,end),'LineWidth',2)
legend('Unfiltered','.25 2-Way','.50 2-Way','.75 2-Way','.25 1-Way','.50 1-Way');
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
plot(tData.tRange,reshape(varData(1,end,:),[1 length(tData.tRange)]),'LineWidth',2)
hold on
grid on
xlabel('Range (km)')
ylabel('Propagation Factor Variance')
plot(tData.tRange,reshape(varData(2,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(varData(3,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(varData(4,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(varData(5,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(varData(6,end,:),[1 length(tData.tRange)]),'LineWidth',2)
legend('Unfiltered','.25 2-Way','.50 2-Way','.75 2-Way','.25 1-Way','.50 1-Way');
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
%plot(tData.tRange,baseRange,'LineWidth',2)
plot(tData.tRange,reshape(meanData(2,end,:),[1 length(tData.tRange)]),'LineWidth',2)
hold on
grid on
xlabel('Range (km)')
ylabel('Propagation Factor Mean Value')
%plot(tData.tRange,reshape(meanData(2,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(meanData(2,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(meanData(3,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(meanData(4,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(meanData(5,end,:),[1 length(tData.tRange)]),'LineWidth',2)
plot(tData.tRange,reshape(meanData(6,end,:),[1 length(tData.tRange)]),'LineWidth',2)
legend('Unfiltered','.25 2-Way','.50 2-Way','.75 2-Way','.25 1-Way','.50 1-Way');
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')