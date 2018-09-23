function [sigma,sigmad,sigmas] = getFPStdDev(L,h1,h2,sigmah,lambda,sf)

k = 2*pi/lambda;
f = 3.0e8/lambda;

sf = 1/4;

re = 6371000*4/3;

graz = asin(h1./L.*(1 + h1/(2*re)) - L/(2*re));


L0 = (h1+h2).^4./(h1*h2.*L .^3);

gam = abs(getReflectionCoefficient( graz,sigmah,lambda));

xtwiddle = sqrt(2./(k*L0));

sigmas = sin(k*2*h1*h2./L).^2;
Q = 2*pi*f*(1-gam)./gam.^2;
alpha = k*L./Q;

sigmad = sf*(1./(pi*alpha)).^(1/4).*(xtwiddle./L);
% sigmad = sqrt(1./(pi*alpha)).*(xtwiddle./L).^2;

sigma = sigmas.*sigmad;