function generatePMSpectra(varargin)

saveFigs = 0;

if nargin == 1
    saveFigs = varargin{1};
end

p = linspace(-4,4,10000);
k = 10.^p;


h(1) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
for (u = 3:2:21) 
   S = PiersonMoskowitz(k,u);
   loglog(k,S, 'LineWidth',2);
   hold on
end


grid on
xlim([10^-3 10^4.5]);
ylim([10^-15 10^3])
xlabel('k (rad/m)');
ylabel('S(k) (m/rad)')
title('Pierson-Moskowitz Variance Spectrum')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

subplot(1,2,2)
for (u = 3:2:21) 
   S = PiersonMoskowitz(k,u);
   loglog(k,k.^3.*S, 'LineWidth',2);
   hold on
end

grid on
xlim([10^-3 10^4.5]);
ylim([10^-4 10^-2])
xlabel('k (rad/m)');
ylabel('k^3S(k) (rad/m)^2)')
title('Pierson-Moskowitz Curvature Spectrum')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

if(saveFigs)
 saveas(h(1),'pm_variance_curvature_spectrum.png','png')
end


