function S = Bretschneider(k,sigmaH)
%S = PiersonMoskowitz(k,sigmaH)

H13 = 4*sigmaH;
%use the absolute value of k so that for 2-sided spectra, S(k) = S(-k)
k = abs(k);

g = 9.81;
omegam = 0.4*sqrt(g/H13);
A = 5*omegam^4./(32*k.^3*g^2)*H13^2;
B = -1.25*omegam^4./(g^2*k.^2);


S = A.*exp(B);