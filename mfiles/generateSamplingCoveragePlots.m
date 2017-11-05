function generateSamplingCoveragePlots(varargin)
%generateSamplingCoveragePlots(varargin)
saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end



U10 = 10;
age = 0.84;

L = 1000;
N1 = 2*L;
N2 = 10*L;
N3 = 118*L;
N4 = 500*L;

dk = 2*pi/L;
k1 = (1:N1/2+1)*dk;
k2 = (1:N2/2+1)*dk;
k3 = (1:N3/2+1)*dk;
k4 = (1:N4/2+1)*dk;


p = linspace(-3,4,1000);
k = 10.^p;

hh(1) = figure('pos',[50 50 917 740]);
subplot(2,2,1)
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
hold on
scatter(k1,Elfouhaily(k1,U10,age),'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
tstring = sprintf('Wave Number Sampling, N = %dL',N1/L);
title(tstring);

subplot(2,2,2)
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
hold on
scatter(k2,Elfouhaily(k2,U10,age),'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
tstring = sprintf('Wave Number Sampling, N = %dL',N2/L);
title(tstring);

subplot(2,2,3)
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
hold on
scatter(k3,Elfouhaily(k3,U10,age),'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
tstring = sprintf('Wave Number Sampling, N = %dL',N3/L);
title(tstring);

subplot(2,2,4)
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
hold on
scatter(k4,Elfouhaily(k4,U10,age),'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
tstring = sprintf('Wave Number Sampling, N = %dL',N4/L);
title(tstring);


%% save figures

if(saveFigs == 1)
    saveas(hh(1),'sampling_coverage.png','png')
end