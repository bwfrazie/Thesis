function plotStatisticSurfaces(dataset,varargin)

x = dataset.tData.tRange;
y = dataset.tData.tAlt;
z = dataset.gsigma;

f = 10e9;
lambda = 3e8/f;

[R,H] = meshgrid(dataset.tData.tRange*1000,dataset.tData.tAlt);

thresh = lambda^2*R.*R./(2*30*H);
% z(thresh < 0.5*30) = 0;

hh(1) = figure();
surfl(x,y,z,'light');
shading interp
light('Position',[-1 -1 0],'Style','local')
xlabel('Range (km)')
ylabel('Altitude (m)')
zlabel('Propagation Factor Standard Deviation')
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')
set(gca,'FontSize',12)
colormap(winter(256))
xlim([10 20])

z = dataset.gmean;
% z(thresh < 0.5*20) = 0;

hh(1) = figure();
surfl(x,y,z,'light');
shading interp
light('Position',[-1 -1 0],'Style','local')
xlabel('Range (km)')
ylabel('Altitude (m)')
zlabel('Propagation Factor Mean')
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')
set(gca,'FontSize',12)
colormap(jet(256))