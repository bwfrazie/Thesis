function h = hankel_error_fit(varargin)

fontSize = 14;
saveFigs = 0;
az1 =-30;
el1 = 75;
az2 = -40;
el2 = -30;
xExtent = [0 15];
yExtent = xExtent;

if nargin == 1
     saveFigs = varargin{1};
 end

x = linspace(xExtent(1),xExtent(2),500);

J = besselj(0,x);
Y = bessely(0,x);
H = J - 1i*Y;

H2 = sqrt(2./(pi*x)).*exp(-1i*x +1i*pi/4);

h(1) = figure;
subplot(2,1,1)
f(1) = plot(x,real(H));
hold on
f(2) = plot(x,real(H2));
grid on
legend('Analytic','Asymptotic')
xlabel('$x$','Interpreter','latex')
ylabel('Re$\{H_0^{(2)}\}$','Interpreter','latex')

subplot(2,1,2)
f(3) = plot(x,imag(H));
hold on
f(4) = plot(x,imag(H2));
grid on
legend('Analytic','Asymptotic')
xlabel('$x$','Interpreter','latex')
ylabel('Im$\{H_0^{(2)}\}$','Interpreter','latex')

set(f,'LineWidth',2)

if saveFigs
    saveas(h(1),'hankel_error.png','png')
end