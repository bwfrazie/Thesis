
% [h, ks, S, V, x, kp, lambda_p] = generateSeaSurface(20000, 40000, 10, 0.84,568194,false);

f = 35e9;
lambda = 3e8/f;
k = 2*pi/lambda;
h1 = 30;
h2 = 5;
L = 5000;
Lo = (h1 + h2).^4./(h1*h2*L^3);

x = linspace(-L,L,1000);


figure
plot(x/1000,real(exp(1i*k*Lo/2*x.^2)));

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlabel('x (km)')
ylabel('Re(exp(ik/2Lox^2))')

