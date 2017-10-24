function generatePMSpectra(varargin)

saveFigs = 0;

if nargin == 1
    saveFigs = varargin{1};
end

p = linspace(-4,4,10000);
k = 10.^p;


h(1) = figure;
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

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

h(2) = figure;
for (u = 3:2:21) 
   S = PiersonMoskowitz(k,u);
   loglog(k,k.^3.*S, 'LineWidth',2);
   hold on
end

grid on
xlim([10^-3 10^4.5]);
ylim([10^-4 10^-2])
xlabel('k (rad/m)');
ylabel('S(k) (rad/m)^2)')

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

if(saveFigs)
 saveas(h(1),'pm_variance_spectrum.png','png')
 saveas(h(2),'pm_curvature_spectrum.png','png')
end


