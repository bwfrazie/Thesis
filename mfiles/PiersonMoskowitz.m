function S = PiersonMoskowitz(k,U10)
%S = PiersonMoskowitz(k,U10)

%use the absolute value of k so that for 2-sided spectra, S(k) = S(-k)
k = abs(k);

U19 = U10*1.026;
g = 9.81;

alpha = 0.0081;
Beta= 0.74;
S = alpha./(2*k.^3).*exp(-Beta*(g./k).^2*1/(U19)^4);