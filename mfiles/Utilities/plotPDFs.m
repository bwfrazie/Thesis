function plotPDFs(fAvg,tRange,tAlt,U10)

%data is organized by range first then alt:
% counter:  1    2    3   4   5   6   7   8
% alt       5    5    5   5   10  10  10  10
% range     5    10   15  20  5   10  15  20

rSize = length(tRange);
aSize = length(tAlt);

slantRange = [];
bw = [];
pdf = [];
xmesh = [];
cdf=[];
colIndex = 1;
for (aIndex = 1:aSize)
    for (rIndex = 1:rSize)
 
        slantRange{colIndex} = sqrt((tRange(rIndex)*1000)^2 + (15-tAlt(rIndex))^2);
        [pdf{colIndex},xmesh{colIndex},bw{colIndex}] = ksdensity(fAvg(:,colIndex));%/slantRange{colIndex}^2);
        colIndex = colIndex + 1;
    end
end

plotStuff(xmesh,pdf,tRange(1),U10,tAlt, 1);
plotStuff(xmesh,pdf,tRange(2),U10,tAlt, 2);
plotStuff(xmesh,pdf,tRange(3),U10,tAlt, 3);
plotStuff(xmesh,pdf,tRange(4),U10,tAlt, 4);

end

function plotStuff(xmesh,pdf,range,U10, alt, index)
    h = figure;
    hold on;
    for (counter = 1:4)
        plot(xmesh{index},pdf{index}, 'LineWidth',2);
        index = index + 4;
    end
    lstring1 = sprintf('%d m Altitude',alt(1));
    lstring2 = sprintf('%d m Altitude',alt(2));
    lstring3 = sprintf('%d m Altitude',alt(3));
    lstring4 = sprintf('%d m Altitude',alt(4));
    legend(lstring1,lstring2,lstring3,lstring4);
    grid on
    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')
    xlabel('F_p')
    ylabel('Probability Density')
    tstring = sprintf('PDF for F_p, R = %d km, U_{10} = %d m/s wind',range, U10);
    title(tstring);
    xm = xlim();
    xlim([0 xm(2)]);
end
