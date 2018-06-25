function plotStatisticSurfaces(dataset,varargin)

x = dataset.tData.tRange;
y = dataset.tData.tAlt;
z = dataset.gsigma;

hh(1) = figure();
surfl(x,y,z,'light');
shading interp
light('Position',[-1 -1 0],'Style','local')
xlabel('Range (km)')
ylabel('Altitude (m)')
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')
set(gca,'FontSize',12)
colormap(winter(256))

z = dataset.gmean;
hh(1) = figure();
surfl(x,y,z,'light');
shading interp
light('Position',[-1 -1 0],'Style','local')
xlabel('Range (km)')
ylabel('Altitude (m)')
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')
set(gca,'FontSize',12)
colormap(jet(256))