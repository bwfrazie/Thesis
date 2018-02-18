import numpy as np
from seaSurfaceGenerationFunctions import *

def generateSeaSurface(L,N,U10,age,phi,useFilter):

	dk = 2*np.pi/L;

	k = np.arange(1e-8,N/2 + 1);
	k = k*dk;

	S = Elfouhaily(k,U10,age,phi);
	
	S[0] = 0;
	
	if useFilter == True:
		co = 0.5
    	#apply the filter
		maxS = np.max(S)

		Spindex = np.where(S==np.max(S))
		Spindex = Spindex[0]
		t1index = np.where (S >= co*maxS)
		S1index = t1index[0]
		S1index = S1index[0]

		t2index = np.where (S[S1index:len(S)] <= co*maxS)
		S2index = t2index[0]
		S2index = S2index[0]

		S[0:S1index] = 0
		S[S2index:len(S)] = 0
 

	V = computeRandomSpectrum(N,S,dk);

	h = np.fft.irfft(V,N)*len(V)

	x = np.arange(0,N)*L/float(N);
	
	return h,x