function PSI= Elfouhaily2D(k,phi,U10,age)
%PSI = Elfouhaily(k,phi, U10,age)

N = size(k,1);
% 
% %constants
g = 9.81; %gravity acceleration
Cd10N = 0.00144; %drag coefficient
ustar = sqrt(Cd10N)*U10;%friction velocity at the water surface
km = 370.0;
cm = 0.23; %minimum phase speed at wavenumber km
k0 = g/(U10^2);
kp = k0 * age^2; %wavenumber of the spectral peak
cp = sqrt(g/kp); %phase speed at the spectral peak cp = U10/age
c = sqrt((g./k).*(1 + (k/km).^2)); %wave phase speed

S = Elfouhaily(k,U10,age);
%% compute the spreading function
a0 = log(2)/2;
ap = 4;
am = 0.13*ustar/cm;

Delk = tanh(a0 + ap*(c/cp).^(2.5) + am*(cm./c).^(2.5));
PSI = S.*1./k.*(1 + Delk.*cos(2*phi));
