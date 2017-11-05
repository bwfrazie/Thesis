function generateOceanSurface2DTestPlots(varargin)
%generateOceanSurface2DTestPlots(varargin)

saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

L = 1000;
N = 2*L;
dx = L/N;
U10 = 10;
age = 0.84;


[h,k,S,V,kx,ky] = generateSeaSurface2D(L, N, U10, age);

x = (0:N-1)*dx;
y = (0:N-1)*dx;

%% Plot the surface
% hh(1) = figure;
% ha = surf(x,y,h,'FaceLighting','gouraud','FaceColor','interp',...
%       'AmbientStrength',0.5);
% shading interp
% light('Position',[0 0 5],'Style','local')
% colormap(winter(256))
% xlim([0 100]);
% ylim([0 100])
% xlabel('x (m)')
% ylabel('y (m)')
% zlabel('h (m)')
% set(gca,'LineWidth',2)
% set(gca,'FontSize',12)
% set(gca,'FontWeight','bold')
% set(gca,'View',[-34, 65]);
% tstring = sprintf('100m^2 Generated 2D Ocean Surface Patch, L = %d m, N = %dL', L, N/L);
% title(tstring);

%% Plot the surface
hh(1) = figure('pos',[50 50 1143 392]);
ax1 = subplot(1,2,1);
surfl(x,y,h,'light');
shading interp
light('Position',[-1 -1 0],'Style','local')
colormap(ax1,winter(256))
xlim([0 100]);
ylim([0 100])
xlabel('x (m)')
ylabel('y (m)')
zlabel('h (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gca,'View',[-34, 65]);
tstring = sprintf('Generated 2-D Surface, 100m^2 Patch, L = %d m, N = %dL', L, N/L);
title(tstring);

%% Plot the surface image
l1 = linspace(0,100,200);
ax2 = subplot(1,2,2);
imagesc(x,y,h);
hold on
colormap(ax2,jet(256))
xlabel('x (m)')
ylabel('y (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
tstring = sprintf('Generated 2-D Surface, L = %d m, N = %dL', L, N/L);
title(tstring);
colorbar

plot(100*ones(size(l1)),l1,'m','LineWidth',2);
plot(1*ones(size(l1)),l1,'m','LineWidth',2);
plot(l1,100*ones(size(l1)),'m','LineWidth',2);
plot(l1,1*ones(size(l1)),'m','LineWidth',2);

%% plot the realization slices and recovered spectra
p = linspace(-3,4,1000);
k1 = 10.^p;
hh(2) = figure('pos',[50 50 872 641]);
Pxx1 = periodogram(h(N/2+1,:),[],'onesided',N,1/dx);
Pxx2 = periodogram(h(:,N/2+1),[],'onesided',N,1/dx);

subplot(2,2,1)
plot(x,h(N/2+1,:),'LineWidth',2);
xlabel('x (m)');
ylabel('h (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
grid on
tstring = sprintf('Sea Surface Y Slice, L = %d m, N = %d',L,N/L);
title(tstring);

subplot(2,2,2)
loglog(kx(N/2+1:end),Pxx1(1:N/2),'LineWidth',2);
hold on
loglog(k1,Elfouhaily(k1,U10,age),'LineWidth',2);
legend('Recovered','1-D S')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
title('X Slice')
tstring = sprintf('Spectrum Comparison, L = %d m, N = %dL',L,N/L);
title(tstring);

subplot(2,2,3)
plot(y,h(:,N/2+1),'LineWidth',2);
xlabel('x (m)');
ylabel('h (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
grid on
tstring = sprintf('Sea Surface Y Slice, L = %d m, N = %dL',L,N/L);
title(tstring);

subplot(2,2,4)
loglog(kx(N/2+1:end),Pxx2(1:N/2),'LineWidth',2);
hold on
loglog(k1,Elfouhaily(k1,U10,age),'LineWidth',2);
legend('Recovered','1-D S')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
title('Y Slice')
tstring = sprintf('Spectrum Comparison, L = %d m, N = %dL',L,N/L);
title(tstring);

%% plot the sampling coverage
figure
loglog(k1,Elfouhaily(k1,U10,age),'LineWidth',2);
hold on
scatter(kx(N/2+1:end),Elfouhaily(kx(N/2+1:end),U10,age),'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')

%%
s1 = std(reshape(h,1,N^2));
dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L,s1);
disp(dispstring);

%% save figures

if(saveFigs == 1)
    saveas(hh(1),'sea_surface_2d_surf.png','png')
    saveas(hh(2),'sea_surface_2d_slices1000.png','png')
end
