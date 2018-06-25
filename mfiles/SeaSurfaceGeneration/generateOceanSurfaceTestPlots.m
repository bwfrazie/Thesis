function generateOceanSurfaceTestPlots(varargin)
%generateOceanSurfaceTestPlots(varargin)
saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

L1 = 1000;
N1 = 500*L1;
N3 = 2*L1;

L2 = 10000;
N2 = 500*L2;
N4 = 2*L2;

U10 = 10;
age = 0.84;

dk1 = 2*pi/L1;
dx1 = L1/N1;

dx3 = L1/N3;

x1 = (0:N1-1)*dx1;
x3 = (0:N3-1)*dx3;

[h1,k1,S1,V1] = generateSeaSurface(L1, N1, U10, age,0,0);
[h3, k3, S3,V1] = generateSeaSurface(L1, N3, U10, age,0,0);

dk2 = 2*pi/L2;
dx2 = L2/N2;
dx4 = L2/N4;

x2 = (0:N2-1)*dx2;
x4 = (0:N4-1)*dx4;

[h2, k2, S2,V2] = generateSeaSurface(L2, N2, U10, age,0,0);
[h4, k4, S4,V4] = generateSeaSurface(L2, N4, U10, age,0,0);

p = linspace(-3,4,1000);
k = 10.^p;

%% plot the sea surface realizations

hh(1) = figure('pos',[50 50 1000 400]);
% hh(1) = figure('pos',[50 50 872 641]);
subplot(1,2,1)
plot(x1,real(h1),'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d km, N = %dL',L1/1000,N1/L1);
title(tstring);

subplot(1,2,2)
plot(x3,real(h3),'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d km, N = %dL',L1/1000,N3/L1);
title(tstring);

%% plot the periodograms
Pxx1 = periodogram(real(h1),[],'onesided',N1,1/dx1)/(2*pi);

hh(2) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
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
tstring = sprintf('Spectrum Comparison, L = %d km, N = %dL',L1/1000,N1/L1);
title(tstring);

Pxx3 = periodogram(real(h3),[],'onesided',N3,1/dx3)/(2*pi);

subplot(1,2,2)
loglog(k3(1:end-1),Pxx3(1:N3/2),'LineWidth',2);
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
tstring = sprintf('Spectrum Comparison, L = %d km, N = %dL',L1/1000,N3/L1);
title(tstring);

%% plot the sea surface realizations
hh(3) = figure('pos',[50 50 1000 400]);

subplot(1,2,1)
plot(x2,h2,'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d km, N = %dL',L2/1000,N2/L2);
title(tstring);
xlim([0 1000])

subplot(1,2,2)
plot(x4,h4,'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d km, N = %dL',L2/1000,N4/L2);
title(tstring);
xlim([0 1000])

%% plot the periodograms

Pxx1 = periodogram(real(h2),[],'onesided',N2,1/dx2)/(2*pi);
hh(4) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
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
tstring = sprintf('Spectrum Comparison, L = %d km, N =%dL',L2/1000,N2/L2);
title(tstring);

Pxx4 = periodogram(real(h4),[],'onesided',N4,1/dx4)/(2*pi);

subplot(1,2,2)
loglog(k4(1:end-1),Pxx1(1:N4/2),'LineWidth',2);
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
tstring = sprintf('Spectrum Comparison, L = %d km, N = %dL',L2/1000,N4/L2);
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
    saveas(hh(3),'sea_surface_10000.png','png')
    saveas(hh(2),'sea_surface_spectra_1000.png','png')
    saveas(hh(4),'sea_surface_spectra_10000.png','png')
end