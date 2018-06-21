
f = 10e9;
lambda = 3e8/f;
sigma = 0.65; 
ko = 2*pi/lambda;
L = linspace(1000,20000,1000);
h2 = 30;
h1 = 30;
xm = h1*L./(h1 + h2);
L0 = (h1 +h2).^4./(h1*h2*L.^3);
graz = atan2(h1,xm);

gamma = abs(getReflectionCoefficient(graz,sigma,lambda));

L1 = xm + (h2-h1).^2./(2*xm);
L2 = xm + h1.^2./(2*xm);
L3 = L-xm + h2.^2./(2*(L-xm));
Lso = L + (h1+h2).^2./(2*L);
sf = h2.*gamma./L3 .* sqrt(L1./(L2.*L3.*L0));

Fp = 20*log10(abs(exp(-1j*ko*L1) + sf.*exp(-1j*ko*Lso)));

plot(L/1000,Fp,'LineWidth',2);
grid on
xlabel('Downrange Distance (km)');
ylabel('Propagation Factor (dB)');
% 
% figure
% plot(h2,Fp,'LineWidth',2);
% grid on
% xlabel('Observation Point Altitude (m)');
% ylabel('Propagation Factor (dB)');
