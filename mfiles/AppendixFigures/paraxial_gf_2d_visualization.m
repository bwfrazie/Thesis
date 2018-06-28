function h = paraxial_gf_2d_visualization(varargin)

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
z = x;
[X,Z] = meshgrid(x,z);
Go2 = sqrt(1./(8*1j*pi*X)).*exp(-j*(X + Z.^2./(2*X)));
z0 = length(x)/2 + 1;

h(1) = figure;
subplot(2,1,1)
f(1) = plot(x,abs(Go2(z0,:)));
xlabel('$k_ox$ (rad)','Interpreter','latex')
ylabel('$k_o|G_o(\mathbf{r},\mathbf{r}'')|$','Interpreter','latex')
grid on
set(gca,'FontSize',fontSize)
xlim(xExtent)

subplot(2,1,2)
f(2) = plot(x,angle(Go2(z0,:)));
xlabel('$k_ox$ (rad)','Interpreter','latex')
ylabel('$\angle G_o(\mathbf{r},\mathbf{r}'')$','Interpreter','latex')
grid on
set(gca,'FontSize',fontSize)
xlim(xExtent)

h(2) = figure;
subplot(2,1,1)
f(3) =  plot(x,real(Go2(z0,:)));
grid on
xlabel('$k_ox$ (rad)','Interpreter','latex')
ylabel('Re$\{k_oG_o(\mathbf{r},\mathbf{r}'')\}$','Interpreter','latex')
set(gca,'FontSize',fontSize)
xlim(xExtent)

subplot(2,1,2)
f(4) =  plot(x,imag(Go2(z0,:)));
grid on
xlabel('$k_ox$ (rad)','Interpreter','latex')
ylabel('Im$\{k_oG_o(\mathbf{r},\mathbf{r}'')\}$','Interpreter','latex')
set(gca,'FontSize',fontSize)
xlim(xExtent)

set(f,'LineWidth',2)

if saveFigs
    saveas(h(1),'2d_paraxial_gf_mag.png','png')
    saveas(h(2),'2d_paraxial_gf_re_im.png','png')
end