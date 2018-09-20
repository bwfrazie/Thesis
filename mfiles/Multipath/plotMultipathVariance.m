function plotMultipathVariance(varargin)

saveFigs = 0;

if (nargin == 1)
    saveFigs = varargin{1};
end

f = 10e9;
lambda = 3e8/10e9;
sigmah = 0.165;


h1 = 30;
h2 = 20;
L = linspace(1000,20000,10000);

sigma_L = getFPStdDev(L,h1,h2,sigmah,lambda);

hh1 = figure;
plot(L/1000,sigma_L,'LineWidth',2)
grid on
xlim([4 20])
xlabel('Down Range Distance (km)')
ylabel('F_p Std. Dev.');
xlim([4 20])
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')


h2 = linspace(1,30,10000);
L = 20000;

sigma_a = getFPStdDev(L,h1,h2,sigmah,lambda);

hh2 = figure;
plot(h2,sigma_a,'LineWidth',2)
grid on
xlim([2 20])
xlabel('Altitude (m)')
ylabel('F_p Std. Dev.');
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')



if(saveFigs == 1)
    saveas(hh1,'std_dev_vs_range','png')
    saveas(hh2,'std_dev_vs_altitude','png')
end