import numpy as np
from seaSurfaceGenerationFunctions import *

def generateSeaSurface(L,N,U10,age):

	dk = 2*np.pi/L;

	k = np.arange(dk,N/2);
	k = k*dk;

	S = Elfouhaily(k,U10,age);
	
	S[0] = 0;
	
	V = computeRandomSpectrum(N,S,dk);

	h = np.fft.irfft(V,N)*len(V)

	x = np.arange(0,N)*L/float(N);
	
	return h,x