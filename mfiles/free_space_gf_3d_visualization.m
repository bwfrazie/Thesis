function h = free_space_gf_3d_visualization(varargin)

fontSize = 14;
saveFigs = 0;
az1 =-30;
el1 = 75;
az2 = -40;
el2 = -30;
xExtent = [-25 25];
yExtent = xExtent;

if nargin == 1
    saveFigs = varargin{1};
end

x = linspace(xExtent(1),xExtent(2),500);
y = x;
[X,Y] = meshgrid(x,y);
R = sqrt(X.*X + Y.*Y);

Go3 = exp(-1i*R)./(4*pi*R);

h(1) = figure;
subplot(2,1,1)
f(1) = mesh(x,y,abs(Go3));
xlabel('$kx$','Interpreter','latex')
ylabel('$ky$','Interpreter','latex')
zlabel('$k|G_o(\mathbf{r},\mathbf{r}'')|$','Interpreter','latex')
colormap(jet(256))
colorbar
set(gca,'FontSize',fontSize)
xlim(xExtent)
ylim(yExtent)

subplot(2,1,2)
f(2) = mesh(x,y,angle(Go3));
xlabel('$kx$','Interpreter','latex')
ylabel('$ky$','Interpreter','latex')
zlabel('$\angle G_o(\mathbf{r},\mathbf{r}'')$','Interpreter','latex')
colormap(jet(256))
colorbar
set(gca,'FontSize',fontSize)
view(az1,el1);
xlim(xExtent)
ylim(yExtent)

h(2) = figure;
subplot(2,1,1)
f(3) = mesh(x,y,real(Go3));
colormap(jet(256));
colorbar
xlabel('$kx$','Interpreter','latex')
ylabel('$ky$','Interpreter','latex')
zlabel('Re$\{kG_o(\mathbf{r},\mathbf{r}'')\}$','Interpreter','latex')
set(gca,'FontSize',fontSize)
xlim(xExtent)
ylim(yExtent)

subplot(2,1,2)
f(4) = mesh(x,y,imag(Go3));
colormap(jet(256));
colorbar
xlabel('$kx$','Interpreter','latex')
ylabel('$ky$','Interpreter','latex')
zlabel('Im$\{kG_o(\mathbf{r},\mathbf{r}'')\}$','Interpreter','latex')
set(gca,'FontSize',fontSize)
view(az2,el2);
xlim(xExtent)
ylim(yExtent)

set(f,'LineWidth',2)

if saveFigs
    saveas(h(1),'3d_fs_gf_mag.png','png')
    saveas(h(2),'3d_fs_gf_re_im.png','png')
end