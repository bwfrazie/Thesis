function generate2DTemporalOceanSurfacePlots(varargin)

saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

[h1, ~, ~, ~, ~, ~,x,y] = generateSeaSurface2D(1000, 2000, 10, 0.84, 0,586194);
[h2, ~, ~, ~, ~, ~,~,~] = generateSeaSurface2D(1000, 2000, 10, 0.84, 2,586194);
[h3, ~, ~, ~, ~, ~,~,~] = generateSeaSurface2D(1000, 2000, 10, 0.84, 4,586194);
[h4, ~, ~, ~, ~, ~,~,~] = generateSeaSurface2D(1000, 2000, 10, 0.84, 6,586194);

hh(1) = figure();
subplot(2,2,1)
imagesc(x,y,h1);
grid on
xlabel('Down Range (m)')
ylabel('Cross Range (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([0 100])
ylim([0 100])
title('0 Seconds')

subplot(2,2,2)
imagesc(x,y,h2);
grid on
xlabel('Down Range (m)')
ylabel('Cross Range (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([0 100])
ylim([0 100])
title('2 Seconds')

subplot(2,2,3)
imagesc(x,y,h3);
grid on
xlabel('Down Range (m)')
ylabel('Cross Range (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([0 100])
ylim([0 100])
title('4 Seconds')

subplot(2,2,4)
imagesc(x,y,h4);
grid on
xlabel('Down Range (m)')
ylabel('Cross Range (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([0 100])
ylim([0 100])
title('6 Seconds')

if(saveFigs == 1)
    saveas(hh(1),'temporal_sea_surfaces_2D.png','png')
end