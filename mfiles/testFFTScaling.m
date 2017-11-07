N = 100000;
L = 500;

dt = L/N;
df = 1/L;

t = (0:N-1)*dt;
f = (0:N/2)*df;

sig1 = 0.5*cos(2*pi*15*t);
sig2 = sig1 + 2*sin(2*pi*21*t);
sig3 = sig2 - 4*cos(2*pi*45*t);

S1 = 2*abs(fft(sig1))/N;
S2 = 2*abs(fft(sig2))/N;
S3 = 2*abs(fft(sig3))/N;

[S4,F] = periodogram(sig3,[],'onesided',length(sig3),1/dt);

S5 = fft(sig3);
S5 = 2*dt/N*abs(S5(1:N/2+1)).^2;

figure
subplot(2,1,1)
plot(f,S5);
grid on;

subplot(2,1,2)
plot(F,S4);
grid on
