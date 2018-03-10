h = figure('Position',[10 100 2000 800]);
surf(xq/1000,yq/1000,hq,'FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.6);
shading interp
light('Position',[0 10 5],'Style','local')
colormap(winter(256))
hold on

xlabel('X (km)')
ylabel('Y (km)')
zlabel('Z (m)')

set(gca,'View',[86 70])
zlim([-5 40])
set(gca,'FontSize',36)
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')

figure

offset = [2000 5000 0];

fcolor = 'white';
fsize = 36;
fweight = 'bold';
lw = 3;

tx = [0 0 50] + offset;
tgt = [24000 -2000 30] + offset;
rx1 = [16000 9000 10] + offset;
rx2 = [26000 8000 10] + offset;

%compute the paths
path1 = tgt - tx;
path2 = rx1 - tgt;
path3 = rx2 - tgt;

theta1 = atan2(path1(2),path1(1))*180/pi;
theta2bound = [atan2(tgt(2) - tx(2), tgt(1) - tx(1)) atan2(rx1(2) - tx(2), rx1(1) - tx(1))]*180/pi;
theta3bound = [atan2(tgt(2) - tx(2), tgt(1) - tx(1)) atan2(rx2(2) - tx(2), rx2(1) - tx(1))]*180/pi;

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

mSize = 250;

line([tx(1)/1000 tgt(1)/1000],[tx(2)/1000 tgt(2)/1000],[tx(3) tgt(3)],'LineWidth',lw,'Color','green');
hold on
line([tgt(1)/1000 rx1(1)/1000],[tgt(2)/1000 rx1(2)/1000],[tgt(3) rx1(3)],'LineWidth',lw,'Color','yellow');
line([tgt(1)/1000 rx2(1)/1000],[tgt(2)/1000 rx2(2)/1000],[tgt(3) rx2(3)],'LineWidth',lw,'Color','yellow');
scatter3(tx(1)/1000,tx(2)/1000,tx(3),mSize,'filled','b')
scatter3(rx1(1)/1000,rx1(2)/1000,rx1(3),mSize,'filled','g')
scatter3(rx2(1)/1000,rx2(2)/1000,rx2(3),mSize,'filled','g')
scatter3(tgt(1)/1000,tgt(2)/1000,tgt(3),mSize,'filled','r')
grid on
% zlim([0 60])

text(tx(1)/1000+.3,tx(2)/1000+.5,tx(3)-2,'Tx','FontWeight','bold','FontSize',fsize)
text(tgt(1)/1000+.2,tgt(2)/1000-3,tgt(3)+5,'Tgt','FontWeight','bold','FontSize',fsize,'Color',fcolor)
text(rx1(1)/1000+.2,rx1(2)/1000+.5,rx1(3),'Rx_1','FontWeight','bold','FontSize',fsize,'Color',fcolor)
text(rx2(1)/1000+.2,rx2(2)/1000+.5,rx2(3),'Rx_2','FontWeight','bold','FontSize',fsize,'Color',fcolor)

tstring = sprintf('%0.0f km',d1);
text(10,-.5,36,tstring,'FontWeight','bold','FontSize',fsize,'Color',fcolor)

tstring = sprintf('%0.0f km',d2);
text(17.5,5.5,20,tstring,'FontWeight','bold','FontSize',fsize,'Color',fcolor)

tstring = sprintf('%0.0f km',d3);
text(28,4.5,20,tstring,'FontWeight','bold','FontSize',fsize,'Color',fcolor)

xlabel('X (km)')
ylabel('Y (km)')
zlabel('Z (m)')

set(gca,'View',[86 70])

set(gca,'FontSize',36)
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')
