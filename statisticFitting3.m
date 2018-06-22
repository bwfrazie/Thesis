
function statisticFitting(data,rangeVec,altVec,range,alt)

rValue = find(rangeVec == range);
aValue = find(altVec == alt);

fp = linspace(0,2,1000);

dataSet = data (:,aValue,rValue)*1/(4*pi*(1000*range)^2);
dist = fitdist(dataSet,'rician');
dist2 = fitdist(dataSet,'normal');
params = dist.ParameterValues;
alpha = 1/(8*pi*params(2)^2);
disp(dist);
disp(dist2);
dispString = sprintf('Alpha = %0.3f',alpha);
disp(dispString);
pdfFit = pdf(dist,fp);
pdfFit2 = pdf(dist2,fp);

histogram(dataSet,'BinMethod','fd','Normalization','pdf')
hold on
plot(fp,pdfFit,'LineWidth',2);
plot(fp,pdfFit2,'LineWidth',2);
lString = sprintf('%d km, %d m',range,alt);
xlabel('|F_p| (unitless)')
ylabel('Density')
g = gca;
ll = g.Legend;
if isempty(ll)
    legend(strcat(lString,' Bins'),strcat(lString,' Fit'));
else
    index = length(ll.String) - 1;
    ll.String(index) = {strcat(lString,' Bins')};
    ll.String(index + 1) = {strcat(lString,' Fit')};
end

grid on
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gca,'LineWidth',2)
hold on