
sigma = 0.65; 
f = 10e9;
lambda = 3e8/f;
k = 2*pi/lambda;
h1 = 30;
h2 = linspace(0,50,1000);
L = 5000;%linspace(0,20000,1000);

h2 = h2 - h2.^2/(2*4/3*6371000);


xm = h1*L./(h1+h2);
L1 = L + (h1-h2).^2./(2*L);
L2 = xm + h1^2./(2*xm);
L3 = L-xm + h2.^2./(2*(L-xm));
graz = atan2(h1,xm);

gam = abs(getReflectionCoefficient(graz,sigma,lambda));

F1 = abs(exp(1j*L1) + gam.*exp(1j*k*(L2 + L3)));
F2 = abs(exp(1j*L1) + gam.*exp(1j*(k*(L2 + L3)+k*pi/4)));

rind = find(data1.r == L/1000);

figure
plot(h2,F1,'LineWidth',2);
hold on
plot(h2,F2,'LineWidth',2);
 plot(data1.h,data1.f(:,rind),'LineWidth',2);
grid on
xlabel('Altitude (m)')
ylabel('|F_p| (unitless)')
legend('2-Ray','Asymptotic','TEMPER')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([0 50])
