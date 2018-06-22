
function [sigma, v, alpha] = statisticFitting2(dataSet,rangeVec,altVec,range,alt,varargin)

plotData = 1;

if nargin == 6
    plotData = varargin{1};
end

aInd = find(altVec == alt);
rInd = find(rangeVec == range);
fp = linspace(0,2,1000);

% dataSet = data (:,aInd,rInd);
dist = fitdist(dataSet,'rician');
params = dist.ParameterValues;
sigma = params(2);
v = params(1);
alpha = 1/(8*pi*params(2)^2);


if plotData == 1
    disp(dist);
    dispString = sprintf('Alpha = %0.3f',alpha);
    disp(dispString);
    pdfFit = pdf(dist,fp);

    figure
    plot(fp,pdfFit,'LineWidth',2);
    lString = sprintf('%d km, %0.1f m',range,alt);
    xlabel('|F_p| (unitless)')
    ylabel('Density')
    g = gca;
    ll = g.Legend;
    if isempty(ll)
        legend(lString);
    else
        index = length(ll.String);
        ll.String(index) = {lString};
    end
    grid on
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')
    set(gca,'LineWidth',2)
    hold on
end
