function generateTemporalOceanSurfacePlots2D(varargin)

saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

t1 = 0;
t2 = 0.2;
t3 = 0.4;
t4 = 0.6;

L = 1000;
N = 2000;

disp('Starting Surface 1 of 4')
[h1, ~, ~, ~, ~, ~,xx,yy] = generateSeaSurface2D(L, N, 10, 0.84, t1, 586194);
disp('Starting Surface 2 of 4')
[h2, ~, ~, ~, ~, ~,~,~] = generateSeaSurface2D(L, N, 10, 0.84, t2, 586194);
disp('Starting Surface 3 of 4')
[h3, ~, ~, ~, ~, ~,~,~] = generateSeaSurface2D(L, N, 10, 0.84, t3, 586194);
disp('Starting Surface 4 of 4')
[h4, ~, ~, ~, ~, ~,~,~] = generateSeaSurface2D(L, N, 10, 0.84, t4, 586194);

limx = [0 100];
limy = [0 100];
indx1 = find(xx == limx(1));
indx2 = find(xx == limx(2));
indy1 = find(yy == limy(1));
indy2 = find(yy == limy(2));

xx = xx(indx1:indx2);
yy = yy(indy1:indy2);

h1 = h1(indy1:indy2,indx1:indx2);
h2 = h2(indy1:indy2,indx1:indx2);
h3 = h3(indy1:indy2,indx1:indx2);
h4 = h4(indy1:indy2,indx1:indx2);

hh(1) = figure('pos',[50 50 917 740]);
subplot(2,2,1)
hold on
surfl(xx,yy,h1,'light');
shading interp
light('Position',[-1 -1 0],'Style','local');%imagesc(xx,yy,h1)
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
xlim(limx);
ylim(limy);
tstring = sprintf('t = %0.1f s',t1);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(winter(256))
set(gca,'View',[-34, 65]);
grid on

subplot(2,2,2)
hold on
surfl(xx,yy,h2,'light');
shading interp
light('Position',[-1 -1 0],'Style','local');%imagesc(xx,yy,h2)
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
xlim(limx);
ylim(limy);
tstring = sprintf('t = %0.1f s',t2);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(winter(256))
set(gca,'View',[-34, 65]);
grid on

subplot(2,2,3)
hold on
surfl(xx,yy,h3,'light');
shading interp
light('Position',[-1 -1 0],'Style','local');%imagesc(xx,yy,h3)
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
xlim(limx);
ylim(limy);
tstring = sprintf('t = %0.1f s',t3);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(winter(256))
set(gca,'View',[-34, 65]);
grid on

subplot(2,2,4)
hold on
surfl(xx,yy,h4,'light');
shading interp
light('Position',[-1 -1 0],'Style','local');%imagesc(xx,yy,h4)
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
xlim(limx);
ylim(limy);
tstring = sprintf('t = %0.1f s',t4);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(winter(256))
set(gca,'View',[-34, 65]);
grid on

if(saveFigs == 1)
    saveas(hh(1),'temporal_sea_surfaces2d.png','png')
end