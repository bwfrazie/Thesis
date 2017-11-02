function [h,S, V] = generateSeaSurface1D(k, dk, U10, age, varargin)
%[h,S, V] = generateSeaSurface(k, dk, U10, age)

if (nargin == 5)
   seed = varargin{1};
   if (seed > 0)
       rng(seed)
   else
       error('Random Number Seed Must be Nonnegative Integer');
   end
end

N = 2*length(k);

S = Elfouhaily(k,U10,age);

%create the random variables
W = randn(1,N);

V = [];
V(1) = sqrt(S(1)/2*dk)*W(1);

for (j = 2: N/2)
    V(j) = sqrt(1/2*S(j)*dk)*1/2*(W(2*j-1) + 1i*W(2*j));
end

V(N/2 + 1) = 0;

for (j = N/2+2:N)
    V(j) = conj(V(N-j + 2));
end

h = ifft(V)*length(V);