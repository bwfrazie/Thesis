function [h, k, S, V, x, kp, lambda_p] = generateSeaSurface(L, N, U10, age, phi,t, varargin)
%[h, k, S, V, x, kp, lambda_p] = generateSeaSurface(L, N, U10, age,phi,t)
%[h, k, S, V, x, kp, lambda_p] = generateSeaSurface(L, N, U10, age,phi,t,seed)

if (nargin >= 7)
   seed = varargin{1};
   if (seed > 0)
       rng(seed)
   else
       error('Random Number Seed Must be Nonnegative Integer');
   end
end


dk = 2*pi/L;
k = (0:N/2)*dk;

%compute the dispersion relation
km = 370.0;
g = 9.81;
omega = sqrt(g*k +(k/km).^2);

[S,kp] = Elfouhaily(k,U10,age,phi);
lambda_p = 2*pi/kp;
S(1) = 0;

%create the random variables

V = [];
w = randn(1,N/2);
u = randn(1,N/2);

V(1) = sqrt(S(1)*dk)*w(1);
for(j = 2:N/2)
    V(j) = 1/2*sqrt(S(j)*dk)*(w(j) + 1i*u(j))*exp(-1i*omega(j)*t);
end
V(N/2+1) = sqrt(S(N/2+1)*dk)*u(1);

for (j = N/2+2:N)
V(j) = conj(V(N-j + 2));
end

%generate the surface and create the x vector for return
h = ifft(V)*length(V);
x = (0:N-1)*L/N;
