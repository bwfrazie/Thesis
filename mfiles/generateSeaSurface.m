function [h,S, V] = generateSeaSurface(k, dk, U10, age, varargin)
%[h,S, V] = generateSeaSurface(k, dk, U10, age)

if (nargin == 5)
   seed = varargin{1};
   if (seed > 0)
       rng(seed)
   else
       error('Random Number Seed Must be Nonnegative Integer');
   end
end

N = 2*(length(k) - 1);

S = Elfouhaily(k,U10,age);

%create the random variables

V = [];
w = randn(1,N/2);
u = randn(1,N/2);

V(1) = sqrt(S(1)/2*dk)*w(1);
for(j = 2:N/2)
    V(j) = 1/2*sqrt(S(j)/2*dk)*(w(j) + 1i*u(j));
end
V(N/2+1) = sqrt(S(N/2+1)/2*dk)*u(1);

for (j = N/2+2:N)
V(j) = conj(V(N-j + 2));
end

h = ifft(V)*length(V);