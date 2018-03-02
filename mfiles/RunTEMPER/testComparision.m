dh = 0.65;
nTrials = 1000;
h2 = 15;
range = 15;

eps = tdata.h(2) - tdata.h(1);

rind = find(tdata.r == range);

rfInd = find(fdataFilt.tRange == range);
afInd = find(fdataUnFilt.tAlt == h2);

fInd = (afInd-1)*4 + rfInd;

w = h2 + dh*randn(nTrials,1);

fTest = zeros(nTrials,1);
for i = 1:length(w)
    fTest(i) = interpolate2DData(tdata.f,tdata.h,tdata.r,w(i),range);
end

[f1,x1] = ksdensity(w);
[f,x] = ksdensity(fTest);

[ff,xf] = ksdensity(fdataFilt.fAvg(:,fInd));
[fu,xu] = ksdensity(fdataUnFilt.fAvg(:,fInd));

figure
subplot(2,2,1)
plot(x1,f1,'LineWidth',2)
grid on
xlabel('Altitude (m)')
ylabel('Probability Density')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([floor(h2-3*dh) ceil(h2+3*dh)])
tstring = sprintf('Altitude Distribution around %0.0f m',h2);
title(tstring);

subplot(2,2,2)
plot(x,f,'LineWidth',2)
grid on
xlabel('Propagation Factor')
ylabel('Probability Density')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
tstring = sprintf('Prop Factor Distribution around %0.0f m',h2);
title(tstring)

subplot(2,2,3)
plot(tdata.h,tdata.f(:,rind),'LineWidth',2)
grid on
xlabel('Altitude (m)')
ylabel('Propagation Factor')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
xlim([floor(h2-3*dh) ceil(h2+3*dh)])
tstring = sprintf('Prop Factor around %0.0f m',h2);
title(tstring)

subplot(2,2,4)

hold on
plot(xf,ff,'LineWidth',2);
hold on
plot(xu,fu,'LineWidth',2);
grid on
xlabel('Propagation Factor')
ylabel('Probability Density')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
legend('Filtered','Unfiltered')

