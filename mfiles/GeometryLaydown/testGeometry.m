tx = [0 0 50];
tgt = [24000 -2000 30];
rx1 = [16000 9000 10];
rx2 = [26000 8000 10];

%compute the paths
path1 = tgt - tx;
path2 = rx1 - tgt;
path3 = rx2 - tgt;

theta1 = atan2(path1(2),path1(1))*180/pi;
theta2bound = [atan2(tgt(2) - tx(2), tgt(1) - tx(1)) atan2(rx1(2) - tx(2), rx1(1) - tx(1))]*180/pi
theta3bound = [atan2(tgt(2) - tx(2), tgt(1) - tx(1)) atan2(rx2(2) - tx(2), rx2(1) - tx(1))]*180/pi

d1 = sqrt(sum(path1.^2))/1000;
d2 = sqrt(sum(path2.^2))/1000;
d3 = sqrt(sum(path3.^2))/1000;

v2 = path2/(d2*1000);
v3 = path3/(d3*1000);

Npoints = 2*15000;
p2 = tgt;
p3 = tgt;
for i = 1:Npoints
    theta2(i) = atan2(p2(2) - tx(2),p2(1) - tx(1));
    p2 = p2 + 0.5*v2;
    
    theta3(i) = atan2(p3(2) - tx(2),p3(1) - tx(1));
    p3 = p3 + 0.5*v3;
end

xx = [tx(1) tgt(1) rx1(1) rx2(1)];
yy = [tx(2) tgt(2) rx1(2) rx2(2)];
zz = [tx(3) tgt(3) rx1(3) rx2(3)];

mSize = 75;

figure
scatter3(tx(1),tx(2),tx(3),mSize,'filled','b')
hold on
scatter3(rx1(1),rx1(2),rx1(3),mSize,'filled','g')
scatter3(rx2(1),rx2(2),rx2(3),mSize,'filled','g')
scatter3(tgt(1),tgt(2),tgt(3),mSize,'filled','r')
line([tx(1) tgt(1)],[tx(2) tgt(2)],[tx(3) tgt(3)],'LineWidth',2);
line([tgt(1) rx1(1)],[tgt(2) rx1(2)],[tgt(3) rx1(3)],'LineWidth',2);
line([tgt(1) rx2(1)],[tgt(2) rx2(2)],[tgt(3) rx2(3)],'LineWidth',2);
grid on
zlim([0 60])

text(tx(1)+300,tx(2)+100,tx(3)-2,'Tx','FontWeight','bold','FontSize',12)
text(tgt(1)+200,tgt(2)+100,tgt(3)+5,'Tgt','FontWeight','bold','FontSize',12)
text(rx1(1)+100,rx1(2)+150,rx1(3),'Rx_1','FontWeight','bold','FontSize',12)
text(rx2(1)+100,rx2(2)+150,rx2(3),'Rx_2','FontWeight','bold','FontSize',12)

tstring = sprintf('%0.0f km',d1);
text(10000,-500,36,tstring,'FontWeight','bold','FontSize',12)

tstring = sprintf('%0.0f km',d2);
text(17500,2500,20,tstring,'FontWeight','bold','FontSize',12)

tstring = sprintf('%0.0f km',d3);
text(27000,1500,20,tstring,'FontWeight','bold','FontSize',12)

xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')

set(gca,'View',[77 41])

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

