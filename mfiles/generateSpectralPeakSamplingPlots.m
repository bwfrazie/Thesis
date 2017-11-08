function generateSpectralPeakSamplingPlots(varargin)

saveFigs = 0;

if (nargin == 1)
    saveFigs = varargin{1};
end

k = linspace(0.005,0.25,5000);
u = 10;

kp = 9.81*(0.84/u)^2;

S = Elfouhaily(k,u,0.84);
peak = max(S);
cutoff = exp(-1)*peak;
half = peak/2;

pindex = find(S == peak);
if(isempty(pindex))
    pindex = find(abs(S-peak) == min(abs(S-peak)),1);
end

cindex = find(S == cutoff);
if(isempty(cindex))
    cindex = find(abs(S(1:pindex)-cutoff) == min(abs(S(1:pindex)-cutoff)),1);
end

hindex = find(S == half);
if(isempty(hindex))
    hindex = find(abs(S(1:pindex)-half) == min(abs(S(1:pindex)-half)),1);
end

dk1 = kp/2;
dk2 = kp/5;
dk3 = kp/10;
dk4 = kp/20;
k1 = (0:round(1/(4*dk1)))*dk1;
k2 = (0:round(1/(4*dk2)))*dk2;
k3 = (0:round(1/(4*dk3)))*dk3;
k4 = (0:round(1/(4*dk4)))*dk4;

testlinep = linspace(0,peak,20);
testlinec = linspace(0,cutoff,20);
testlineh = linspace(0,half,20);


%%
testline1 = linspace(kp,0.25,20);
testline2 = linspace(k(hindex),0.25,20);
h(1) = figure('pos',[50 50 917 740]);

subplot(2,2,1)
plot(k,S,'LineWidth',2);
grid on
hold on
stem(k1,Elfouhaily(k1,u,0.84),'--','LineWidth',1);
xlabel('k (rad/m)')
ylabel('S (m^3/rad)')
tstring = sprintf('\\Delta k = 1/%d k_p',kp/dk1);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
plot(testline1,S(pindex)*ones(length(testlinep)),'--k','LineWidth',2);
plot(testline2,S(hindex)*ones(length(testlineh)),'--k','LineWidth',2);
scatter(k(hindex),half,75,'dk','LineWidth',2);
scatter(kp,peak,75,'dk','LineWidth',2);

subplot(2,2,2)
plot(k,S,'LineWidth',2);
grid on
hold on
stem(k2,Elfouhaily(k2,u,0.84),'--','LineWidth',1);
xlabel('k (rad/m)')
ylabel('S (m^3/rad)')
tstring = sprintf('\\Delta k = 1/%d k_p',kp/dk2);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
plot(testline1,S(pindex)*ones(length(testlinep)),'--k','LineWidth',2);
plot(testline2,S(hindex)*ones(length(testlineh)),'--k','LineWidth',2);
scatter(k(hindex),half,75,'dk','LineWidth',2);
scatter(kp,peak,75,'dk','LineWidth',2);

subplot(2,2,3)
plot(k,S,'LineWidth',2);
grid on
hold on
stem(k3,Elfouhaily(k3,u,0.84),'--','LineWidth',1);
xlabel('k (rad/m)')
ylabel('S (m^3/rad)')
tstring = sprintf('\\Delta k = 1/%d k_p',kp/dk3);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
plot(testline1,S(pindex)*ones(length(testlinep)),'--k','LineWidth',2);
plot(testline2,S(hindex)*ones(length(testlineh)),'--k','LineWidth',2);
scatter(k(hindex),half,75,'dk','LineWidth',2);
scatter(kp,peak,75,'dk','LineWidth',2);

subplot(2,2,4)
plot(k,S,'LineWidth',2);
grid on
hold on
stem(k4,Elfouhaily(k4,u,0.84),'--','LineWidth',1);
xlabel('k (rad/m)')
ylabel('S (m^3/rad)')
tstring = sprintf('\\Delta k = 1/%d k_p',kp/dk4);
title(tstring)
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
plot(testline1,S(pindex)*ones(length(testlinep)),'--k','LineWidth',2);
plot(testline2,S(hindex)*ones(length(testlineh)),'--k','LineWidth',2);
scatter(k(hindex),half,75,'dk','LineWidth',2);
scatter(kp,peak,75,'dk','LineWidth',2);

if(saveFigs == 1)
    saveas(h(1),'spectral_peak_sampling','png')
end
