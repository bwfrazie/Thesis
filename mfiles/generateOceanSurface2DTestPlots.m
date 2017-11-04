function generateOceanSurface2DTestPlots(varargin)
%generateOceanSurface2DTestPlots(varargin)

saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

L = 1000;
M = 13;
N = 2^M;
dx = L/N;
U10 = 10;
age = 0.84;


[h,k,S,V,kx,ky] = generateSeaSurface2D(L, N, U10, age);

x = (0:N-1)*dx;
y = (0:N-1)*dx;

%% Plot the surface
hh(1) = figure;
surf(x,y,h,'FaceLighting','gouraud','FaceColor','interp',...
      'AmbientStrength',0.5);
shading interp
light('Position',[-1 0 0],'Style','local')
colormap winter
xlim([0 100]);
ylim([0 100])
xlabel('x (m)')
ylabel('y (m)')
zlabel('h (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gca,'View',[-34, 65]);
title('Generated 2D Ocean Surface, 100 m^2 Patch')

%% Plot the surface image
hh(2) = figure;
imagesc(x,y,h);
colormap jet
xlabel('x (m)')
ylabel('y (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
title('Generated 2D Ocean Surface')
colorbar

%% plot the realization slices and recovered spectra
p = linspace(-3,4,1000);
k1 = 10.^p;
hh(3) = figure('pos',[50 50 872 641]);
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
tstring = sprintf('Sea Surface Y Slice, L = %d km, N = 2^{%d}',L/1000,M);
title(tstring);

subplot(2,2,2)
loglog(kx(N/2+1:end),Pxx1(1:N/2),'LineWidth',2);
hold on
loglog(k1,Elfouhaily(k1,U10,age),'LineWidth',2);
legend('Recovered','Original')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
title('X Slice')
tstring = sprintf('Spectrum Comparison, L = %d km, N = 2^{%d}',L/1000,M);
title(tstring);

subplot(2,2,3)
plot(y,h(:,N/2+1),'LineWidth',2);
xlabel('x (m)');
ylabel('h (m)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
grid on
tstring = sprintf('Sea Surface Y Slice, L = %d km, N = 2^{%d}',L/1000,M);
title(tstring);

subplot(2,2,4)
loglog(kx(N/2+1:end),Pxx2(1:N/2),'LineWidth',2);
hold on
loglog(k1,Elfouhaily(k1,U10,age),'LineWidth',2);
legend('Recovered','Original')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
title('Y Slice')
tstring = sprintf('Spectrum Comparison, L = %d km, N = 2^{%d}',L/1000,M);
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
    saveas(hh(1),'sea_surface_2d_image.png','png')
    saveas(hh(3),'sea_surface_2d_slices1000.png','png')
end
