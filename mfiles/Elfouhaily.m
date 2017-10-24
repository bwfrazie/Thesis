function S = Elfouhaily(k,U10,age)
%S = Elfouhaily(k,U10,age)

%constants
g = 9.81; %gravity acceleration
Cd10N = 0.00144; %drag coefficient
ustar = sqrt(Cd10N)*U10;%friction velocity at the water surface
km = 370.0;
cm = 0.23; %minimum phase speed at wavenumber km
sigma = 0.08*(1+4*age^(-3));
alphap = 0.006*age^(0.55); %generalizaed Phillips-Kitaigorodskii equilibrium range parameter for long waves
k0 = g/(U10^2);
kp = k0 * age^2; %wavenumber of the spectral peak
cp = sqrt(g/kp); %phase speed at the spectral peak cp = U10/age

if (ustar <= cm) %alpham is the generalizaed Phillips-Kitaigorodskii equilibrium range parameter for short waves
    alpham = 0.01*(1 + log(ustar/cm));
else
    alpham = 0.01*(1 + 3*log(ustar/cm));
end

if (age <= 1)
    gamma = 1.7;
else
    gamma = 1.7 + 6*log(age);
end

c = sqrt((g./k).*(1 + (k/km).^2)); %wave phase speed
Lpm = exp(-5/4*(kp./k).^2);  %Pierson-Moskowitz shape spectrum
Gam = exp(-1/(2*sigma^2)*(sqrt(k/kp) - 1 ).^2 );
Jp = gamma.^Gam; %JONSWAP peak enhancement or "overshoot" factor
Fp = Lpm.*Jp.*exp(-age/sqrt(10)*(sqrt(k/kp) - 1) ); %long-wave side effect function
Fm = Lpm.*Jp.*exp(-0.25*(k/km - 1).^2); %short-wave side effect function
Bl = 0.5*alphap*(cp./c).*Fp;
Bh = 0.5*alpham*(cm./c).*Fm;

S = (Bl + Bh)./(k.^3);
