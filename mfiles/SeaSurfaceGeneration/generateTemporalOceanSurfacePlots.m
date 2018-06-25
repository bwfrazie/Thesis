function generateTemporalOceanSurfacePlots(varargin)

saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

[h, ~, ~, ~, x, ~, ~] = generateSeaSurface(20000, 100000, 10, 0.84, 0,0, 586194);
[h1, ~, ~, ~, ~, ~, ~] = generateSeaSurface(20000, 100000, 10, 0.84, 0,1, 586194);
[h2, ~, ~, ~, ~, ~, ~] = generateSeaSurface(20000, 100000, 10, 0.84, 0,2, 586194);
[h3, ~, ~, ~, ~, ~, ~] = generateSeaSurface(20000, 100000, 10, 0.84, 0,3, 586194);

hh(1) = figure();
plot(x,h,'LineWidth',2);
hold on
plot(x,h1,'LineWidth',2);
plot(x,h2,'LineWidth',2);
plot(x,h3,'LineWidth',2);
grid on
xlim([0 500]);
xlabel('Down Range Distance (m)')
ylabel('Wave Height')
legend('0 sec','1 sec','2 sec','3 sec','Location','SouthWest');


set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

if(saveFigs == 1)
    saveas(hh(1),'temporal_sea_surfaces.png','png')
end