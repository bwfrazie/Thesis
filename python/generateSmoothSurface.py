import numpy as np

def generateSmoothSurface(L,N,U10,age,phi,useFilter):

	x = np.arange(0,N)*L/float(N);
	h = np.sin(2*np.pi*.001*x);
	
	return h,x