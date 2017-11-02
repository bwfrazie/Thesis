function generateOceanSurfaceTestPlots(varargin)
%generateOceanSurfaceTestPlots(varargin)
saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

L1 = 1000;
M1 = nextpow2(118*L1);
N1 = 2^M1;

L2 = 10000;
M2 = nextpow2(118*L2);
N2 = 2^M2;

U10 = 10;
age = 0.84;


dk1 = 2*pi/L1;
dx1 = L1/N1;
k1 = (1:N1/2+1)*dk1;

x1 = (0:N1-1)*dx1;

[h1,S1,V1] = generateSeaSurface(k1, dk1, U10, age);

dk2 = 2*pi/L2;
dx2 = L2/N2;
k2 = (1:N2/2+1)*dk2;

x2 = (0:N2-1)*dx2;

[h2,S2,V2] = generateSeaSurface(k2, dk2, U10, age);

%% plot the sea surface realizations
hh(1) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
plot(x1,real(h1),'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d m, N = 2^{%d}',L1,M1);
title(tstring);

p = linspace(-3,4,1000);
k = 10.^p;

Pxx1 = periodogram(real(h1),[],'onesided',N1,1/dx1);

subplot(1,2,2)
loglog(k1(1:end-1),Pxx1(1:N1/2),'LineWidth',2);
hold on
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
legend('Recovered','Original')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
tstring = sprintf('Spectrum Comparison, L = %d m, N = 2^{%d}',L1,M1);
title(tstring);

%% plot the sea surface realizations
hh(2) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
plot(x2,h2,'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d m, N = 2^{%d}',L2,M2);
title(tstring);

p = linspace(-3,4,1000);
k = 10.^p;

Pxx1 = periodogram(real(h2),[],'onesided',N2,1/dx2);

subplot(1,2,2)
loglog(k2(1:end-1),Pxx1(1:N2/2),'LineWidth',2);
hold on
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
legend('Recovered','Original')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^3/rad)')
tstring = sprintf('Spectrum Comparison, L = %d m, N = 2^{%d}',L2,M2);
title(tstring);

%% 
s1 = std(h1);
dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L1,s1);
disp(dispstring);

s2 = std(h2);
dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L2,s2);
disp(dispstring);

%% save figures

if(saveFigs == 1)
    saveas(hh(1),'sea_surface_1000.png','png')
    saveas(hh(2),'sea_surface_10000.png','png')
end