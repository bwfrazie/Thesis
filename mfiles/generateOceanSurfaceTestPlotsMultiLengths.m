function generateOceanSurfaceTestPlots(varargin)
%generateOceanSurfaceTestPlots(varargin)
saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

L1 = 1000;
L2 = 10000;
L3 = 30000;
% L4 = 30000;
N = 2^20;

U10 = 10;
age = 0.84;

seed = 567890423;

%% work through L1 case first
dk1 = 2*pi/L1;
dx1 = L1/N;
k1 = (1:N/2)*dk1;
x1 = (0:N-1)*dx1;

[h1,S1,V1] = generateSeaSurface(k1, dk1, U10, age, seed);

%% work through L2 case next
dk2 = 2*pi/L2;
dx2 = L2/N;
k2 = (1:N/2)*dk2;
x2 = (0:N-1)*dx2;

[h2,S2,V2] = generateSeaSurface(k2, dk2, U10, age, seed);

%% work through L3 case next
dk3 = 2*pi/L3;
dx3 = L3/N;
k3 = (1:N/2)*dk3;
x3 = (0:N-1)*dx3;

[h3,S3,V3] = generateSeaSurface(k3, dk3, U10, age, seed);

%% work through L4 case next
% dk4 = 2*pi/L4;
% dx4 = L4/N;
% k4 = (1:N/2)*dk4;
% x4 = (0:N-1)*dx4;
% 
% [h4,S4,V4] = generateSeaSurface(k4, dk4, U10, age, seed);

%% plot the sea surface realizations
hh(1) = figure('pos',[10 10 1100 400]);
subplot(1,3,1)
plot(x1,real(h1),'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d m',L1);
title(tstring);
axis square

subplot(1,3,2)
plot(x2,real(h2),'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d m',L2);
title(tstring);
axis square

subplot(1,3,3)
plot(x3,real(h3),'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (m)')
ylabel('h (m)')
tstring = sprintf('Sea Surface, L = %d m',L3);
title(tstring);
axis square

% subplot(2,2,4)
% plot(x4,real(h4),'LineWidth',2);
% grid on
% set(gca,'LineWidth',2)
% set(gca,'FontSize',12)
% set(gca,'FontWeight','bold')
% xlabel('x (m)')
% ylabel('h (m)')
% tstring = sprintf('Sea Surface, L = %d m',L4);
% title(tstring);
%% plot the coefficients
z1 = fft(h1)/N;
z2 = fft(h2)/N;
z3 = fft(h3)/N;
% z4 = fft(h4)/N;

hh(2) = figure('pos',[10 10 1100 400]);
subplot(1,3,1)
semilogy(abs(V1),'LineWidth',2);
hold on
semilogy(abs(z1),'LineWidth',2);
grid on
legend('Original','Recovered', 'Location','SouthEast')
xlabel('Index')
xlim([1 N]);
ylim([10^-20 10^5]);
ylabel('|V|')
tstring = sprintf('Coefficient Test, L = %d m',L1);
title(tstring);
axis square

subplot(1,3,2)
semilogy(abs(V2),'LineWidth',2);
hold on
semilogy(abs(z2),'LineWidth',2);
grid on
legend('Original','Recovered', 'Location','SouthEast')
xlabel('Index')
xlim([1 N]);
ylim([10^-20 10^5]);
ylabel('|V|')
tstring = sprintf('Coefficient Test, L = %d m',L2);
title(tstring);
axis square

subplot(1,3,3)
semilogy(abs(V3),'LineWidth',2);
hold on
semilogy(abs(z3),'LineWidth',2);
grid on
legend('Original','Recovered', 'Location','SouthEast')
xlabel('Index')
xlim([1 N]);
ylim([10^-20 10^5]);
ylabel('|V|')
tstring = sprintf('Coefficient Test, L = %d m',L3);
title(tstring);
axis square

% subplot(2,2,4)
% semilogy(abs(V4),'LineWidth',2);
% hold on
% semilogy(abs(z4),'LineWidth',2);
% grid on
% legend('Original','Recovered')
% xlabel('Index')
% xlim([1 N]);
% ylabel('|V|')
% tstring = sprintf('Coefficient Test, L = %d m',L4);
% title(tstring);

%% plot the difference in random variables
hh(3) = figure('pos',[10 10 1100 400]);
subplot(1,3,1)
semilogy(abs(z1-V1),'LineWidth',2);
grid on
xlabel('Index j')
ylabel('|V-V''|')
xlim([1 N]);
tstring = sprintf('Coefficient Difference, L = %d m',L1);
title(tstring);
axis square

subplot(1,3,2)
semilogy(abs(z2-V2),'LineWidth',2);
grid on
xlabel('Index j')
ylabel('|V-V''|')
xlim([1 N]);
tstring = sprintf('Coefficient Difference, L = %d m',L2);
title(tstring);
axis square

subplot(1,3,3)
semilogy(abs(z3-V3),'LineWidth',2);
grid on
xlabel('Index j')
ylabel('|V-V''|')
xlim([1 N]);
tstring = sprintf('Coefficient Difference, L = %d m',L3);
title(tstring);
axis square

% subplot(2,2,4)
% semilogy(abs(z4-V4),'LineWidth',2);
% grid on
% xlabel('Index j')
% ylabel('Difference in |V|')
% xlim([1 N]);
% tstring = sprintf('Coefficient Difference, L = %d m',L4);
% title(tstring);

%% compare the spectra

Pxx1 = periodogram(real(h1),[],'onesided',N,1/dx1);
Pxx2 = periodogram(real(h2),[],'onesided',N,1/dx2);
Pxx3 = periodogram(real(h3),[],'onesided',N,1/dx3);
% Pxx4 = periodogram(real(h4),[],'onesided',N,1/dx4);

hh(4) = figure('pos',[10 10 1100 400]);
subplot(1,3,1)
loglog(k1,Pxx1(1:N/2),'LineWidth',2);
hold on
loglog(k1,S1,'LineWidth',2)
legend('Recovered','Original')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^2/rad/m)')
tstring = sprintf('Spectrum Test, L = %d m',L1);
title(tstring);
axis square

subplot(1,3,2)
loglog(k2,Pxx2(1:N/2),'LineWidth',2);
hold on
loglog(k2,S2,'LineWidth',2)
legend('Recovered','Original')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^2/rad/m)')
tstring = sprintf('Spectrum Test, L = %d m',L2);
title(tstring);
axis square

subplot(1,3,3)
loglog(k3,Pxx3(1:N/2),'LineWidth',2);
hold on
loglog(k3,S3,'LineWidth',2)
legend('Recovered','Original')
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^2/rad/m)')
tstring = sprintf('Spectrum Test, L = %d m',L3);
title(tstring);
axis square

% subplot(2,2,4)
% loglog(k4,Pxx4(1:N/2),'LineWidth',2);
% hold on
% loglog(k4,S4,'LineWidth',2)
% legend('Recovered','Original')
% ylim([10^-15 10^3])
% xlim([10^-3 10^5]);
% grid on
% set(gca,'LineWidth',2)
% set(gca,'FontSize',12)
% set(gca,'FontWeight','bold')
% xlabel('k (rad/m)')
% ylabel('S(k) (m/rad)')
% tstring = sprintf('Spectrum Test, L = %d m',L4);
% title(tstring);
%% plot the sampled points
p = linspace(-3,4,1000);
k = 10.^p;

hh(5) = figure('pos',[10 10 1100 400]);
subplot(1,3,1)
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
tstring = sprintf('Wave Number Sampling, L = %d m',L1);
title(tstring);
% axis square
% 
subplot(1,3,2)
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
hold on
scatter(k2,S2,'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^2/rad/m)')
tstring = sprintf('Wave Number Sampling, L = %d m',L2);
title(tstring);
% axis square

subplot(1,3,3)
loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
hold on
scatter(k3,S3,'LineWidth',2);
ylim([10^-15 10^3])
xlim([10^-3 10^5]);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('k (rad/m)')
ylabel('S(k) (m^2/rad/m)')
tstring = sprintf('Wave Number Sampling, L = %d m',L3);
title(tstring);
% axis square

% subplot(2,2,4)
% loglog(k,Elfouhaily(k,U10,age),'LineWidth',2);
% hold on
% scatter(k4,S4,'LineWidth',2);
% ylim([10^-15 10^3])
% xlim([10^-3 10^5]);
% grid on
% set(gca,'LineWidth',2)
% set(gca,'FontSize',12)
% set(gca,'FontWeight','bold')
% xlabel('k (rad/m)')
% ylabel('S(k) (m/rad)')
% tstring = sprintf('Wave Number Sampling, L = %d m',L4);
% title(tstring);
%% 
s1 = std(h1);
dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L1,s1);
disp(dispstring);

s2 = std(h2);
dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L2,s2);
disp(dispstring);

s3 = std(h3);
dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L3,s3);
disp(dispstring);

% s4 = std(h4);
% dispstring = sprintf('Standard Deviation of Wave Height for L = %d m is %0.3f', L4,s4);
% disp(dispstring);
%% save figures

if(saveFigs == 1)
    
    saveas(hh(1),'sea_surface_test.png','png')
    saveas(hh(2),'random_variable_test.png','png')
    saveas(hh(3),'random_variable_diff_test.png','png')
    saveas(hh(4),'power_spectrum_test.png','png')
    saveas(hh(5),'sampling_test.png','png')
end