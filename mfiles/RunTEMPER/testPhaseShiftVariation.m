
r = linspace(1000,30000,1000);
re = 4/3*6371000;

h1 = 30;
h2 = 5;

lambda = 3e8/35e9;
k = 2*pi/lambda;
deltaS = 0.0;

p1 = sqrt(r.^2 + (h1 - h2).^2);
p2 = sqrt(r.^2 + (h1 + h2).^2);

dp1 = r./p1;
dp2 = r./p2;

figure
subplot(2,1,1)
dphi = 2*pi/lambda*(dp1 - dp2);
plot(r/1000,dphi,'LineWidth',2)
grid on
xlabel('Range (km)','Interpreter','latex')
ylabel('$\partial{\varphi}/\partial{r}$ (rad/m)','Interpreter','latex')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

subplot(2,1,2)
phi = exp(1j*2*pi/lambda*(p1 - p2));
plot(r/1000,phi,'LineWidth',2)
grid on
xlabel('Range (km)','Interpreter','latex')
ylabel('$\varphi$ (rad)','Interpreter','latex')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')