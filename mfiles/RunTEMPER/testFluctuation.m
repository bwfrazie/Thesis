
% [h, ks, S, V, x, kp, lambda_p] = generateSeaSurface(20000, 40000, 10, 0.84,568194,false);
% 
f = 35e9;
lambda = 3e8/f;
k = 2*pi/lambda;
h1 = 30;
h2 = 20;


L = 10000;

Lo = (h1+h2)^4/(2*h1*h2*L^3);

x = linspace(-10000,10000,1000);
y = exp(1i*k*Lo/2*x.^2);

plot(x/1000,real(y))


% N = 40000;
% Gamma = 1;
% sf = (h1 + h2)^2/(h1*h2);
% 
% %loop
% for counter = 1:N
%     xx = x(1:counter);
%     hh = h(1:counter);
%     
%     Fs = 1/L*exp(1j*k*L);
%     Lo = (h1 + h2)^4/(h1*h2*L^3);
% 
%     dtest = 1/L*exp(1j*k*Lo/2*xx.^2 - 1j*k*hh*2*(h1 + h2)/L);
%     test = sum(dtest);
%     
%     F(counter) = Fs*(1 + Gamma*sf*test);
% end
% 
% figure
% plot(x,abs(F),'LineWidth',2)

