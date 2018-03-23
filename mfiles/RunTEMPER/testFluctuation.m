
% [h, ks, S, V, x, kp, lambda_p] = generateSeaSurface(20000, 40000, 10, 0.84,568194,false);

f = 35e9;
lambda = 3e8/f;
k = 2*pi/lambda;
h1 = 30;
h2 = 20;%linspace(5,20,100);


L = linspace(1000,20000,10000);
L1 = L + (h1-h2).^2./(2*L);
Lso = L + (h1 + h2).^2./(2*L);

Gamma = 1;

Lo2 = (h1 + h2).^4./(h1*h2*L.^3);
Lo = (h1 + h2).^2./(2*L);

Fp1 = exp(1i*k*L1) + Gamma*exp(1i*k*Lso);
Fp2 = exp(1i*k*L1) - Gamma*exp(1i*(k*Lso + pi/4)).*1;%sqrt(2*pi./(k*Lo2));

figure
plot(L/1000,abs(Fp1),'LineWidth',2);

hold on
plot(L/1000,abs(Fp2),'--');
xlim([4 20])
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

