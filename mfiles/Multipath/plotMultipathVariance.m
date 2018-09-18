%function plotMultipathVariance(varargin)

saveFigs = 0;

% if (nargin == 1)
%     saveFigs = varargin{1};
% end

lambda = 3e8/10e9;
k = 2*pi/lambda;

sigmah = 0.165;

re = 6371000*4/3;
h1 = 30;
h2 = 20;
L = linspace(1000,20000,10000);

graz = asin(h1./L*(1 + h1/(2*re)) - L/(2*re));
gam = abs(getReflectionCoefficient( graz,sigmah,lambda));

L0 = (h1+h2).^4./(h1*h2*L.^3);
L1 = L + (h1-h2).^2./(2*L);
Lm = L + (h1+h2).^2./(2*L);

Ld = 2*h1*h2./L;
xtwiddle = sqrt(2./(k*L0));

ofact = sin(k*2*h1*h2./L).^2;


value = abs(exp(1j*k*L1) + exp(1j*k*Lm));

h = figure;
plot(L/1000,value,'LineWidth',2);
hold on
grid on
xlabel('Down Range Distance (km)')
ylabel('F_p (unitless)');
xlim([4 20])
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

if(saveFigs == 1)
    saveas(h,'two_ray_multipath_results','png')
end