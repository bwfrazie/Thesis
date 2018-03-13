
r = linspace(1000,30000,5000);
re = 4/3*6371000;

h1 = 30;
h2 = 15;

f = 35e9;

lambda = 3e8/f;
k = 2*pi/lambda;
deltaS = 0.0;

p1 = sqrt(r.^2 + (h1 - h2).^2);
p2 = sqrt(r.^2 + (h1 + h2).^2);

dp1 = r./p1;
dp2 = r./p2;

dphi = 2*pi*lambda/lambda*(dp1 - dp2)*0.5;
phi = 2*pi/lambda*(p1-p2);

pdphi = pchip(r,dphi);
pphi = pchip(r,phi);

dr = 0.1*lambda^2*r.^2/(2*h1*h2);
dr1 = 1/20*lambda^2*r.^2/(2*h1*h2);

figure
plot(r/1000,dr,'LineWidth',2);
hold on
plot(r/1000,dr1,'LineWidth',2);
grid on
xlabel('Range (km)')
ylabel('\Delta r')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

figure
subplot(2,1,1)

plot(r/1000,dphi,'LineWidth',2)
grid on
xlabel('Range (km)','Interpreter','latex')
ylabel('$d \varphi/dr$ (cycles/sample)','FontSize',12,'FontWeight','bold','Interpreter','latex')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

subplot(2,1,2)
plot(r/1000,phi,'LineWidth',2)
grid on
xlabel('Range (km)','Interpreter','latex')
ylabel('$\varphi$ (rad)','Interpreter','latex')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')