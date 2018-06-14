function h = free_space_gf_2d_visualization(varargin)

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
rho = sqrt(X.*X + Y.*Y);
J = besselj(0,rho);
Y = bessely(0,rho);

Go2 = -1i/4*(J - 1i*Y);

h(1) = figure;
subplot(2,1,1)
f(1) = mesh(x,y,abs(Go2));
xlabel('$kx$ (rad)','Interpreter','latex')
ylabel('$ky$ (rad)','Interpreter','latex')
zlabel('$k|G_o(\mathbf{r},\mathbf{r}'')|$','Interpreter','latex')
colormap(jet(256))
colorbar
set(gca,'FontSize',fontSize)
xlim(xExtent)
ylim(yExtent)

subplot(2,1,2)
f(2) = mesh(x,y,angle(Go2));
xlabel('$kx$ (rad)','Interpreter','latex')
ylabel('$ky$ (rad)','Interpreter','latex')
zlabel('$\angle G_o(\mathbf{r},\mathbf{r}'')$','Interpreter','latex')
colormap(jet(256))
colorbar
set(gca,'FontSize',fontSize)
view(az1,el1);
xlim(xExtent)
ylim(yExtent)

h(2) = figure;
subplot(2,1,1)
f(3) = mesh(x,y,real(Go2));
colormap(jet(256));
colorbar
xlabel('$kx$ (rad)','Interpreter','latex')
ylabel('$ky$ (rad)','Interpreter','latex')
zlabel('Re$\{kG_o(\mathbf{r},\mathbf{r}'')\}$','Interpreter','latex')
set(gca,'FontSize',fontSize)
xlim(xExtent)
ylim(yExtent)

subplot(2,1,2)
f(4) = mesh(x,y,imag(Go2));
colormap(jet(256));
colorbar
xlabel('$kx$ (rad)','Interpreter','latex')
ylabel('$ky$ (rad)','Interpreter','latex')
zlabel('Im$\{kG_o(\mathbf{r},\mathbf{r}'')\}$','Interpreter','latex')
set(gca,'FontSize',fontSize)
view(az2,el2);
xlim(xExtent)
ylim(yExtent)

set(f,'LineWidth',2)

if saveFigs
    saveas(h(1),'2d_fs_gf_mag.png','png')
    saveas(h(2),'2d_fs_gf_re_im.png','png')
end