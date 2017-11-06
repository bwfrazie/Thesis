function generate2DElfouhailySpectra(varargin)

saveFigs = 0;

if nargin == 1
    saveFigs = varargin{1};
end

dk = 0.0025;
N = 4000;
kx = (-N/2+1:N/2)*dk;
ky = kx';

[kxx,kyy] = meshgrid(kx,ky);

%convert to polar coordinates
[phi,k] = cart2pol(kxx,kyy);

h(1) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)

S = Elfouhaily2D(k,phi,10,0.84);
S1 = Elfouhaily(kx,10,0.84);
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

h(2) = figure;%('pos',[50 50 1000 400]);
Sx = S(N/2,:);
Sy = S(:,N/2);
loglog(kx(N/2:end),Sx(N/2:end));
hold on
loglog(ky(N/2:end),Sy(N/2:end));
loglog(kx(N/2:end),S1(N/2:end));
legend('\Phi_x','\Phi_y','S');
xlim([0 370]);
ylim([10^-15 10^3])
grid on

if(saveFigs)
 saveas(h(1),'elf_variance_curvature_spectrum.png','png')
end


