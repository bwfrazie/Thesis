
% [h, ks, S, V, x, kp, lambda_p] = generateSeaSurface(20000, 40000, 10, 0.84,568194,false);

f = 35e9;
lambda = 3e8/f;
k = 2*pi/lambda;
h1 = 30;
h2 = 10;%linspace(5,20,100);

L = [10000 20000 30000 100000];

re = 4/3*6371000;
Rh = (sqrt(2*re*h1 + h1^2) + sqrt(2*re*h2 + h2^2));


Lo = [];
y = [];
x = [];


for counter = 1:length(L)
    if L(counter) > Rh
        L(counter) = Rh;
    end

    xm(counter) = h1*L(counter)/(h1+h2);
    Lo(counter) = (h1+h2)^4/(2*h1*h2*L(counter)^3);
    x(counter,:) = linspace(-2*L(counter)/2,2*L(counter)/2,1000);
    y(counter,:) = exp(1i*k*Lo(counter)/2*x(counter,:).^2);
end

figure

ind = 1;
tstring = sprintf('L = %0.1f km',L(ind)/1000);
subplot(2,2,ind)
plot(x(ind,:)/1000,real(y(counter,:)),'LineWidth',2)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
grid on
xlim([-xm(ind)/1000 (L(ind)-xm(ind))/1000])
xlabel('\textbf{$\mathbf{\tilde{x}}$ (km)}','Interpreter','Latex')
ylabel('Re\{F\}')
title(tstring);

ind = 2;
tstring = sprintf('L = %0.1f km',L(ind)/1000);
subplot(2,2,ind)
plot(x(ind,:)/1000,real(y(counter,:)),'LineWidth',2)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
grid on
xlim([-xm(ind)/1000 (L(ind)-xm(ind))/1000])
xlabel('\textbf{$\mathbf{\tilde{x}}$ (km)}','Interpreter','Latex')
ylabel('Re\{F\}')
title(tstring);

ind = 3;
tstring = sprintf('L = %0.1f km',L(ind)/1000);
subplot(2,2,ind)
plot(x(ind,:)/1000,real(y(counter,:)),'LineWidth',2)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
grid on
xlim([-xm(ind)/1000 (L(ind)-xm(ind))/1000])
xlabel('\textbf{$\mathbf{\tilde{x}}$ (km)}','Interpreter','Latex')
ylabel('Re\{F\}')
title(tstring);

ind = 4;
tstring = sprintf('L = %0.1f km',L(ind)/1000);
subplot(2,2,ind)
plot(x(ind,:)/1000,real(y(counter,:)),'LineWidth',2)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
grid on
xlim([-xm(ind)/1000 (L(ind)-xm(ind))/1000])
xlabel('\textbf{$\mathbf{\tilde{x}}$ (km)}','Interpreter','Latex')
ylabel('Re\{F\}')
title(tstring);

