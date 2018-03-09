h = figure('Position',[10 100 1000 400]);
aind = find(abs(data1.h - 15) < 0.025);
hold on
rind = find(data1.r == 20);
plot(data1.r,abs(data1.f(aind,:)),'LineWidth',3)
plot(data2.r,abs(data2.f(aind,:)),'--','LineWidth',3)
grid on
xlabel('Down Range (km)')
ylabel('|F_p|')
set(gca,'LineWidth',2)
set(gca,'FontSize',28)
set(gca,'FontWeight','bold')
xlim([10 50])