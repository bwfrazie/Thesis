function generate2DElfouhailySpectra(varargin)

saveFigs = 0;

if nargin == 1
    saveFigs = varargin{1};
end

U10 = 10;
age = 0.84;
kx = linspace(-400,400,2000);
ky = kx';

[kxx,kyy] = meshgrid(kx,ky);

%convert to polar coordinates
[phi,k] = cart2pol(kxx,kyy);

S = Elfouhaily2D(k,phi,U10,age);

p = linspace(-4,4,10000);
k1 = 10.^p;

Sx = Elfouhaily2D(k1,zeros(size(k1)),U10,age);
Sy = Elfouhaily2D(k1,pi/2*ones(size(k1)),U10,age);
S1 = Elfouhaily(k1,U10,age);

h(1) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
imagesc(kx,ky,10*log10(S));
caxis([-125 -30])
grid on
xlabel('k_x (rad/m)');
ylabel('k_y (rad/m)')
title('10log_{10}(\Psi)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(jet(256))
colorbar

subplot(1,2,2) 
imagesc(kx,ky,10*log10(k.^4.*S));

grid on
xlabel('k_x (rad/m)');
ylabel('k_y (rad/m)')
title('10log_{10}(k^4\Psi)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(jet)
colorbar

%% plot the zoomed in spectrum
h(2) = figure;
kx2 = linspace(-2,2,1000);
ky2 = kx2';
[kxx2,kyy2] = meshgrid(kx2,ky2);

%convert to polar coordinates
[phi2,k2] = cart2pol(kxx2,kyy2);
S2 = Elfouhaily2D(k2,phi2,U10,age);
imagesc(kx2,ky2,10*log10(S2));
caxis([-35 20]);
grid on
xlabel('k_x (rad/m)');
ylabel('k_y (rad/m)')
title('10log_{10}(\Psi)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(jet(256))
colorbar

%% plot the spectrum slices
h(3) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
loglog(k1,Sx);
hold on
loglog(k1, Sy);
loglog(k1,S1);
legend('\Psi_x','\Psi_y','S');
xlim([10^-3 10^5]);
ylim([10^-15 10^5]);
grid on
title('Variance Spectrum Comparison of 2D Slices and 1D')

subplot(1,2,2)
loglog(k1,k1.^4.*Sx);
hold on
loglog(k1,k1.^4.*Sy);
loglog(k1,k1.^3.*S1);
legend('k^4\Psi_x','k^4\Psi_y','k^3S');
xlim([10^-3 10^5]);
ylim([10^-4 10^0]);
grid on
title('Curvature Spectrum Comparison of 2D Slices and 1D')

if(saveFigs)
 saveas(h(1),'elf_variance_curvature_spectrum_2D.png','png')
 saveas(h(2),'elf_variance_curvature_spectrum_2D_zoom.png','png')
 saveas(h(3),'elf_variance_curvature_spectrum_2D_slices.png','png')
end


