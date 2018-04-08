function testPlotData(tData,meanData,varData)

h = figure('Position',[10 100 2000 800]);
surf(tData.tAlt,tData.tRange,squeeze(meanData(1,:,:))','FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.5);
hold on
surfc(tData.tAlt,tData.tRange,sqrt(squeeze(varData(1,:,:)))','FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.75)
shading interp
light('Position',[0 10 5],'Style','local')
colormap(hsv(256))
xlabel('Altitude (m)')
ylabel('Range (km)')
zlabel('Value (m)')
% ylim([10 20])
% xlim([2 30])
set(gca,'FontSize',36)
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')

h = figure('Position',[10 100 2000 800]);
surfc(tData.tAlt,tData.tRange,sqrt(squeeze(varData(1,:,:)))','FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.75)
shading interp
light('Position',[0 10 5],'Style','local')
% colormap(hsv(256))
xlabel('Altitude (m)')
ylabel('Range (km)')
zlabel('Std Dev (m)')

% ylim([10 20])
% xlim([2 30])
set(gca,'FontSize',36)
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')

h = figure('Position',[10 100 2000 800]);
surf(tData.tAlt,tData.tRange,squeeze(meanData(1,:,:))','FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.5);
hold on
surfc(tData.tAlt,tData.tRange,squeeze(meanData(3,:,:))','FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.5);
shading interp
light('Position',[0 10 5],'Style','local')
% colormap(winter(256))
xlabel('Altitude (m)')
ylabel('Range (km)')
zlabel('Mean (m)')
% ylim([10 20])
% xlim([2 30])
set(gca,'FontSize',28)
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')
