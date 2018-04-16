
p10 = {};
p5 = {};
pdf10 = {};
pdf5 = {};
S21_10 = [];
S21_5 = [];
alpha10 = [];
alpha5 = [];
gam10 = [];
gam5=[];
v10 = [];
m10 = [];
v5 = [];
L = [];
xm = [];
graz = [];
m5 = [];
x = [];
F1_10=[];
F2_10=[];
F1_5=[];
F2_5=[];
h1 = 30;
f = 10e9;
lambda = 3e8/f;
k = 2*pi/lambda;
f = 2.997e8/lambda;
    
Re = 64.18/(1 + 3.30523e-21*f^2) + 4.9;
Im = 3.68972e-9*f/(1 + 3.30523e-21*f^2) + 9.4e10/f;
    
epsr = Re + 1j*Im;
    
fp = linspace(0,2,1000);
mdata10 = mean(data10,1);
mdata5 = mean(data5,1);
vdata10 = std(data10,[],1);
vdata5 = std(data5,[],1);

for cnt = 1:9
    p10{cnt} = fitdist(data10(:,cnt),'rician');
    pdf10{cnt} = pdf(p10{cnt},fp);
    v10(cnt) = p10{cnt}.std;
    m10(cnt) = p10{cnt}.mean;
    p5{cnt} = fitdist(data5(:,cnt),'rician');
    pdf5{cnt} = pdf(p5{cnt},fp);
    v5(cnt) = p5{cnt}.std;
    m5(cnt) = p5{cnt}.mean;
    
    t = p10{cnt}.ParameterValues;
    alpha10(cnt) = 1/(8*pi*t(2)^2);
    S21_10(cnt) = t(1);
    t = p5{cnt}.ParameterValues;
    alpha5(cnt) = 1/(8*pi*t(2)^2);
    S21_5(cnt) = t(1);
    
    h2 = alt(cnt);
    L(cnt) = range(cnt)*1000;
    Lo = (h1 + h2)^4/(h1*h2*L(cnt)^3);
    x(cnt) = 2*sqrt(pi/(k*Lo));
    
    xm(cnt) = h1*L(cnt)./(h1+h2);
    graz(cnt) = atan2(h1,xm(cnt));
    gam10(cnt) = abs(getReflectionCoefficient(graz(cnt),0.65,lambda));
    gam5(cnt) = abs(getReflectionCoefficient(graz(cnt),0.16,lambda));
    
    h2 = h2 - L(cnt).^2/(2*4/3*6371000);
     
    L1 = L(cnt) + (h1-h2).^2./(2*L(cnt));
    L2 = xm(cnt) + h1^2./(2*xm(cnt));
    L3 = L(cnt)-xm(cnt) + h2.^2./(2*(L(cnt)-xm(cnt)));
    
   
    
    F1_10(cnt) = abs(exp(1j*L1) + gam10(cnt).*exp(1j*k*(L2 + L3)));
    F2a_10(cnt) = abs(exp(1j*L1) + gam10(cnt).*exp(1j*(k*(L2 + L3)+k*(pi/4))));
    F2_10(cnt) = abs(exp(1j*L1) + gam10(cnt).*exp(1j*(k*(L2 + L3)+k*(pi))));
    F1_5(cnt) = abs(exp(1j*L1) + gam5(cnt).*exp(1j*k*(L2 + L3)));
    F2_5(cnt) = abs(exp(1j*L1) + gam5(cnt).*exp(1j*(k*(L2 + L3)+k*(pi/4 ))));
end

figure
plot(fp,pdf10{3},'LineWidth',2);
l1 = sprintf('%d km, %d m',range(3),alt(3));
hold on
plot(fp,pdf10{6},'LineWidth',2);
l2 = sprintf('%d km, %d m',range(6),alt(6));
plot(fp,pdf10{9},'LineWidth',2);
l3 = sprintf('%d km, %d m',range(9),alt(9));
xlabel('|F_p| (unitless)')
ylabel('Density')
legend(l1,l2,l3);
grid on
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gca,'LineWidth',2)

figure
plot(fp,pdf5{3},'LineWidth',2);
l1 = sprintf('%d km, %d m',range(3),alt(3));
hold on
plot(fp,pdf5{6},'LineWidth',2);
l2 = sprintf('%d km, %d m',range(6),alt(6));
plot(fp,pdf5{9},'LineWidth',2);
l3 = sprintf('%d km, %d m',range(9),alt(9));
xlabel('|F_p| (unitless)')
ylabel('Density')
legend(l1,l2,l3);
grid on
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gca,'LineWidth',2)


figure
sz = 150;
temp = 1:9;
scatter(temp,mdata10,sz,'bo');
hold on
scatter(temp,m10,sz,'bx');
scatter(temp,vdata10,sz,'bs');
scatter(temp,v10,sz,'b+');

scatter(temp,mdata5,sz,'ro');
scatter(temp,m5,sz,'rx');
scatter(temp,vdata5,sz,'rs');
scatter(temp,v5,sz,'r+');
xlabel('Sample Point')
ylabel('Value (unitless)')
grid on
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gca,'LineWidth',2)

figure
sz = 400;
temp = [5 15 30];
tind = [1 2 3];
scatter(temp,S21_10(tind),sz,'filled','bo');
hold on
% scatter(temp,F2a_10(tind),sz,'filled','rs');
scatter(temp,F2_10(tind),sz,'filled','rs');

legend('Fit','Predicted - \pi')
xlabel('Altitude')
ylabel('|S_{21}| (unitless)')
grid on
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gca,'LineWidth',2)
