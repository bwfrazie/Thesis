function generateOceanSurfaceTestPlots(varargin)
%generateOceanSurfaceTestPlots(varargin)
saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

L1 = 1000;
M = 20;
N = 2^M;

U10 = 10;
age = 0.84;


dk1 = 2*pi/L1;
dx1 = L1/N;
k1 = (1:N/2)*dk1;
x1 = (0:N-1)*dx1;

[h1,S1,V1] = generateSeaSurface(k1, dk1, U10, age);

%% plot the sea surface realizations
hh(1) = figure('pos',[10 10 950 700]);
subplot(2,2,1)
plot(x1,real(h1),'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d m, N = 2^{%d}',L1,M);
title(tstring);

subplot(2,2,2)
semilogy(abs(V1),'LineWidth',2);
grid on
xlabel('Index')
xlim([1 N]);
ylim([10^-20 10^5]);
ylabel('|V|')
tstring = sprintf('Coefficient Test, L = %d m, N = 2^{%d}',L1,M);
title(tstring);
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

p = linspace(-3,4,1000);
k = 10.^p;

Pxx1 = periodogram(real(h1),[],'onesided',N,1/dx1);

subplot(2,2,3)
loglog(k1,Pxx1(1:N/2),'LineWidth',2);
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
ylabel('S(k) (m^2/rad/m)')
tstring = sprintf('Spectrum Test, L = %d m, N = 2^{%d}',L1,M);
title(tstring);

subplot(2,2,4)
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
hold on
scatter(k1,S1,'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^2/rad/m)')
tstring = sprintf('Wave Number Sampling, L = %d m, N = 2^{%d}',L1,M);
title(tstring);
%% 
s1 = std(h1);
dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L1,s1);
disp(dispstring);


%% save figures

if(saveFigs == 1)
    saveas(hh(1),'sea_surface_test1.png','png')
end