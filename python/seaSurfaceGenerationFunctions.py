import numpy as np

def Elfouhaily(kin, U10, age):
	
	#constants
	g = 9.81; #gravity acceleration
	Cd10N = 0.00144 #drag coefficient
	ustar = np.sqrt(Cd10N)*U10 #friction velocity at the water surface
	km = 370.0
	cm = 0.23 #minimum phase speed at wavenumber km
	sigma = 0.08*(1+4*age**(-3))
	alphap = 0.006*age**(0.55) #generalized Phillips-Kitaigorodskii equilibrium range parameter for long waves
	k0 = g/(U10**2)
	kp = k0 * age**2 #wavenumber of the spectral peak
	cp = np.sqrt(g/kp) #phase speed at the spectral peak cp = U10/age

	if (ustar <= cm): #alpham is the generalizaed Phillips-Kitaigorodskii equilibrium range parameter for short waves
		alpham = 0.01*(1 + np.log(ustar/cm))
	else:
		alpham = 0.01*(1 + 3*np.log(ustar/cm))
		
		print"here"

	if (age <= 1):
		gamma = 1.7
	else:
		gamma = 1.7 + 6*np.log(age)

	print gamma
	S = np.empty([len(kin)+1,1],float)
	for ind in range(0,len(kin)):
		k = kin[ind]
		c = np.sqrt((g/k)*(1 + (k/km)**2)) #wave phase speed
		Lpm = np.exp(-5/4*(kp/k)**2)  #Pierson-Moskowitz shape spectrum
		Gam = np.exp(-1/(2*sigma**2)*(np.sqrt(k/kp) - 1 )**2 )
		Jp = gamma**Gam #JONSWAP peak enhancement or "overshoot" factor
		Fp = Lpm*Jp*np.exp(-age/np.sqrt(10)*(np.sqrt(k/kp) - 1) ) #long-wave side effect function
		Fm = Lpm*Jp*np.exp(-0.25*(k/km - 1)**2) #short-wave side effect function
		Bl = 0.5*alphap*(cp/c)*Fp
		Bh = 0.5*alpham*(cm/c)*Fm
		print ind
		print Bl
		print Bh
		print k
		S[ind] = (Bl + Bh)/(k**3);
		print S[ind]
	return S
