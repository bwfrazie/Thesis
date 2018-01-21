import numpy as np
from seaSurfaceGenerationFunctions import *


U10 = 10
age = 0.84
L = 10000
N = 2*L

dk = 2*np.pi/L

k = np.arange(0,N/2)
k = k*dk
print k
print len(k)

S = Elfouhaily(k,U10,age);
S[0] = 0;
#create the random variables

V = np.ndarray((N,),complex)

w = np.random.normal(0,1,N/2)
u = np.random.normal(0,1,N/2)

V[0] = np.sqrt(S[0]*dk)*w[0]

for i in range(1,N/2 - 1):
	V[i] = 1/2*np.sqrt(S[i]*dk)*(w[i] + 1j*u[i]);

V[N/2] = np.sqrt(S[N/2]*dk)*u[0]

for i in range(N/2, N-1):
	V[i] = np.conj(V[N-i + 1]);

h = np.fft.ifft(V)*len(V);

print h