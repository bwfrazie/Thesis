sig1 = 1;
sig2 = sig1;

f = 10e9;
lambda = 3e8/f;
k = 2*pi/lambda;


R = 10000;%4*lambda;
L = 100;%2*lambda;%1000;
x1 = -1/2*L;
x2 = 1/2*L;
y1 = 0;
y2 = 0;
theta = linspace(0,360,500);


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

figure
h = polarplot(theta*pi/180,s);