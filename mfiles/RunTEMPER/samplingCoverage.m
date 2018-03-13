
r = linspace(0,20000,500);
h1 = 30;
h2 = linspace(5,30,500);

[rr,hh] = meshgrid(r,h2);

h1 = 30;

f = 10e9;

lambda = 3e8/f;
k = 2*pi/lambda;

dr = 1/10*lambda^2*rr.^2./(2*h1*hh);
dr1 = 1/20*lambda^2*rr.^2./(2*h1*hh);
dr2 = 0.5*ones(10,10);

dh = 1/20*lambda^2*r.^2/(2*h1*0.5);

figure
plot(r/1000,dh,'LineWidth',2)
xlabel('Range (km)')
ylabel('Height (m)')

figure
surfc(h2,r/1000,dr,'FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.75)
hold on
mesh(linspace(5,30,10),linspace(0,20,10),dr2)%'FaceLighting','gouraud','FaceColor','interp','AmbientStrength',0.75)
shading interp
light('Position',[0 10 5],'Style','local')
colormap(hsv(256))
xlabel('Altitude (m)')
ylabel('Range (km)')
zlabel('Value (m)')
set(gca,'FontSize',36)
set(gca,'LineWidth',2)
set(gca,'FontWeight','bold')
zlim([0 1])