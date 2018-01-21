function estimatePDFs(data,U10,varargin)

saveFigs = 0;
if nargin == 3
    saveFigs = varargin{1};
end
nRanges = length(data.tRange);
nAlts = length(data.tAlt);

%counter goes in range and then altitude
for rCounter = 1:nRanges
    h(rCounter) = figure;
    hold on
    lstring = [];
    for aCounter = 1:nAlts
        index = (aCounter - 1)*nRanges + rCounter;
        [f,x] = ksdensity(data.fAvg(:,index));

        plot(x,f,'LineWidth',2)
        lstring{aCounter} = sprintf('%d m',data.tAlt(aCounter));
    end
    grid on;
    xlabel('Target Altitude (m)')
    ylabel('Prop Factor (dB)')
    legend(lstring);
    tstring = sprintf('Range = %d km, U_{10} = %d m/s', data.tRange(rCounter),U10);
    title(tstring);
    set(gca,'LineWidth',2);
    set(gca,'FontWeight','bold');
    set(gca,'FontSize',12);
    xlim([0 2])
   
end

if(saveFigs == 1)
    for counter = 1:nRanges
        fname = sprintf('EstimatedPDF_%d_m_s_%d_km',U10,data.tRange(counter));
        saveas(h(counter),fname,'png')
    end
end