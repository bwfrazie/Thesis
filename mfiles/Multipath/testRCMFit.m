
sigma = 0.65; 
f = 10e9;
lambda = 3e8/f;
k = 2*pi/lambda;
h1 = 30;
h2 = linspace(0,100,1000);
L = 10000;

% h2 = h2 - L.^2/(2*4/3*6371000);

La = (h1-h2).^2./(2*L);
Lb = (h1+h2).^2./(2*L);
Lc = -2*sigma*(h1+h2)/L;



xm = h1*L./(h1+h2);
L1 = L + (h1-h2).^2./(2*L);
L2 = xm + h1^2./(2*xm);
L3 = L-xm + h2.^2./(2*(L-xm));
graz = atan2(h1,xm);
L0 = (h1+h2).^4./(h1*h2*L^3);

gam = abs(getReflectionCoefficient(graz,sigma,lambda));
sig = 2*sigma*k*(h1+h2)/L;

figure
plot(h2,besselj(0,s),'LineWidth',2)
