function generateElfouhailyVsPMSpectra(varargin)

saveFigs = 0;

if nargin == 1
    saveFigs = varargin{1};
end

p = linspace(-3,4,1000);
k = 10.^p;

S5pm = PiersonMoskowitz(k,5);
S10pm = PiersonMoskowitz(k,10);

S5e = Elfouhaily(k,5,0.84);
S10e = Elfouhaily(k,10,0.84);

h(1) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
loglog(k,S5pm,'LineWidth',2);
hold on
loglog(k,S10pm,'LineWidth',2);

loglog(k,S5e,'--','LineWidth',2);
loglog(k,S10e,'--','LineWidth',2);

grid on;
xlim([10^-3 10^5]);
ylim([10^-15 10^3])

l1 = linspace(-16,3,26);
l = 10.^l1;
plot(370*ones(size(l)),l,'k','LineWidth',2);
text(370,10^-5,'\leftarrow k = 370 rad/m','FontWeight','bold','FontSize',12)

legend('PM, U_{10} = 5m/s','PM,  U_{10} = 10 m/s','E,  U_{10} = 5 m/s','E,  U_{10} = 10 m/s')
xlabel('k (rad/m)');
ylabel('S(k) (m^3/rad)')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
title('Variance Spectra')
set(gca,'FontWeight','bold')

subplot(1,2,2)
loglog(k,k.^3.*S5pm,'LineWidth',2);
hold on
loglog(k,k.^3.*S10pm,'LineWidth',2);
loglog(k,k.^3.*S5e,'--','LineWidth',2);
loglog(k,k.^3.*S10e,'--','LineWidth',2);

l1 = linspace(-16,3,26);
l = 10.^l1;
plot(370*ones(size(l)),l,'k','LineWidth',2);
text(370,10^-1.5,'\leftarrow k = 370 rad/m','FontWeight','bold','FontSize',12)

grid on;
xlim([10^-3 10^5]);
ylim([10^-4 10^0])

legend('PM,  U_{10} = 5m/s','PM,  U_{10} = 10 m/s','E,  U_{10} = 5 m/s','E,  U_{10} = 10 m/s')
xlabel('k (rad/m)');
ylabel('k^3S(k) (rad^2)')

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
title('Curvature Spectra')
if(saveFigs)
 saveas(h(1),'elf_vs_PM_variance_curvature_spectrum.png','png')
end
