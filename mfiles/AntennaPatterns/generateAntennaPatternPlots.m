function generateAntennaPatternPlots(varargin)
%generateAntennaPatternPlots(varargin)
saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

f = 35e9;
lambda = 3e8/f;


D = 10.19*lambda;
r = 10000;
l = lambda;
theta = linspace(-pi/4,pi/4,1000);

E = sin(pi*D/lambda.*sin(theta))./(pi*D/lambda*sin(theta));
Edb = 20*log10(abs(E));

ind1 = find(Edb >= -3,1);
ind2 = find(Edb(ind1+1:end) <= -3, 1) + ind1;

bw = abs(theta(ind2) - theta(ind1))*180/pi;

h(1) = figure;
plot(theta*180/pi,Edb,'LineWidth',2);
xlabel('\theta (deg)')
ylabel('|E(\theta)| (dB)')
grid on
text(theta(ind1)*180/pi - 4,Edb(ind1),'\rightarrow','FontSize',12,'FontWeight','bold')
text(theta(ind2)*180/pi + 1,Edb(ind2),'\leftarrow','FontSize',12,'FontWeight','bold')
tstring = sprintf('One Way Antenna Pattern, Beam Width  = %0.2f deg',bw);
title(tstring)

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([-45 45])
%%
E2 = E.*E;
E2db = 20*log10(abs(E2));

ind3 = find(E2db >= -3,1);
ind4 = find(E2db(ind3+1:end) <= -3, 1) + ind3;

bw2 = abs(theta(ind4) - theta(ind3))*180/pi;

h(2) = figure;
plot(theta*180/pi,E2db,'LineWidth',2);
xlabel('\theta (deg)')
ylabel('|E(\theta)|^2 (dB)')
grid on
text(theta(ind3)*180/pi - 4,E2db(ind3),'\rightarrow','FontSize',12,'FontWeight','bold')
text(theta(ind4)*180/pi + 1,E2db(ind4),'\leftarrow','FontSize',12,'FontWeight','bold')
tstring = sprintf('Two Way Antenna Pattern, Beam Width = %0.2f deg',bw2);
title(tstring)

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([-45 45])
%%

if(saveFigs == 1)
    saveas(h(1),'sinc_antenna_pattern_one_way.png','png')
    saveas(h(2),'sinc_antenna_pattern_two_way.png','png')
end