function generate2DElfouhailySpectra(varargin)

saveFigs = 0;

if nargin == 1
    saveFigs = varargin{1};
end

kx = linspace(-370,370,1000);
ky = kx';

[kxx,kyy] = meshgrid(kx,ky);

%convert to polar coordinates
[phi,k] = cart2pol(kxx,kyy);

h(1) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)

S = Elfouhaily2D(k,phi,20,0.84);
imagesc(kx,ky,10*log10(S));%,[-150 30]);
hold on

grid on
% xlim([10^-3 10^5]);
% ylim([10^-3 10^5]);
% ylim([10^-15 10^3])
xlabel('k_x (rad/m)');
ylabel('k_y (rad/m)')
title('Elfouhaily 2-D Variance Spectrum (m^4/rad^2)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(jet(256))
colorbar

subplot(1,2,2) 
imagesc(kx,ky,k.^4.*S);

grid on
% xlim([10^-3 10^5]);
% ylim([10^-4 10^0])
xlabel('k_x (rad/m)');
ylabel('k_y (rad/m)')
title('Elfouhaily 2-D Curvature Spectrum (rad^2)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
colormap(jet)
colorbar

if(saveFigs)
 saveas(h(1),'elf_variance_curvature_spectrum.png','png')
end


