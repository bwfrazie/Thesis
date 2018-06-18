sig1 = 1;
sig2 = 0.25*sig1;

f = 10e9;
lambda = 3e8/f;
k = 2*pi/lambda;


R = 1000;
L = [1 2 5 10];

figure;

for (testCounter = 1:length(L))
    
x1 = -1/2*L(testCounter)*lambda;
x2 = 1/2*L(testCounter)*lambda;
y1 = 0;
y2 = 0;
theta = linspace(0,360,2000);


x3 = R*cos(theta*pi/180);
y3 = R*sin(theta*pi/180);

vx1 = x3-x1;
vx2 = x3-x2;
vy1 = y3-y1;
vy2 = y3-y2;

vxt = sqrt(sig1)*vx1 + sqrt(sig2)*vx2;
vyt = sqrt(sig1)*vy1 + sqrt(sig2)*vy2;

d1 = sqrt((x3-x1).^2 + (y3-y1).^2);
p1 = exp(-1j*2*k*d1);
d2 = sqrt((x3-x2).^2 + (y3-y2).^2);
p2 = exp(-1j*2*k*d2);

s = abs(sqrt(sig1).*p1 + sqrt(sig2).*p2).^2;

subplot(2,2,testCounter)
h = polarplot(theta*pi/180,s,'LineWidth',2);
grid on
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
tstring = sprintf('%d Wavelength Spacing',L(testCounter));
title(tstring);
end

