% function [h,S, V] = generateSeaSurface2D(kx, ky, phi, dk, U10, age, varargin)
%[h,S, V] = generateSeaSurface(kx, ky,phi, dk, U10, age)
% 
% if (nargin == 5)
%    seed = varargin{1};
%    if (seed > 0)
%        rng(seed)
%    else
%        error('Random Number Seed Must be Nonnegative Integer');
%    end
% end
% 
% N = 2*size(kx,1);
L = 100;
N = 2^2;
del_x = L/N;
U10 = 10;
age = 0.84;

%setup the PSD
del_k = 1/(N*del_x); %frequency grid spacing (1/m)
kx = (-N/2: N/2-1) * del_k; 

%frequency grid (rad/m)
[kxx,kyy] = meshgrid(kx);
[phi, k] = cart2pol(kxx, kyy); %polar grid


S = Elfouhaily2D(k,phi,U10,age);

S = S/2*del_k^2;

%create the random variables
V = [];

% W1 = randn((N)^2,1);
% W2 = randn((N)^2,1);
% 
% counter = 1;
% 
% for (row = 1:N)
%     for(col = 1:row)
%         if(row == col)
%             V(row,col) = sqrt(S(row,col))*W1(counter);
%         else
%             V(row,col) = sqrt(S(row,col))*1/2*(W1(counter) + 1i*W2(counter));
%             V(col,row) = conj(V(row,col));
%         end
%         counter = counter + 1;
%     end
% end
% 
% V(1,1) = 0.0;

W1 = randn(N);
W2 = randn(N);

for u = 1:N
    for v = 1:N
        indU = N - u + 1;
        indV = N - v + 1;
        V(u,v) =    W1(u,v)*sqrt(S(u,v)) + W1(indU,indV)*sqrt(S(indU,indV)) + ...
                1i*(W2(u,v)*sqrt(S(u,v)) - W2(indU,indV)*sqrt(S(indU,indV)));
    end
end

for v = 2:N/2
    indV = N - v + 1;
    V(1,v) =    W1(1,v)*sqrt(S(1,v)) + W1(1,indV)*sqrt(S(1,indV)) + ...
            1i*(W2(1,v)*sqrt(S(1,v)) - W2(1,indV)*sqrt(S(1,indV)));
   V(1,indV) = conj(V(1,v));
end

for (u = 2:N/2)
    indU = N - u + 1;
    V(u,1) =    W1(u,1)*sqrt(S(u,1)) + W1(indU,1)*sqrt(S(indU,1)) + ...
                1i*(W2(u,1)*sqrt(S(u,1)) - W2(indU,1)*sqrt(S(indU,1)));
            
    V(indU,1) = conj(V(u,1));
end

V(N/2 + 1, N/2 + 1) = 0.0;
V = 1/2*V;

h = ifft2(V)*length(V)^2;
x = (0:N-1)*del_x;
y = (0:N-1)*del_x;

figure;
surf(x,y,real(h),'FaceLighting','gouraud');
shading interp
colormap jet

