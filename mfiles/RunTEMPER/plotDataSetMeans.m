function plotDataSetMeans(dataset,varargin)

type = 'alt';

if nargin == 2
    type = varargin{1};
end

if strcmpi(type,'alt')
    plot(dataset.tData.tAlt,dataset.meanData(1,:,end),'LineWidth',2)
    hold on
    grid on
    xlabel('Altitude (m)')
    ylabel('Propagation Factor Mean')
    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')
elseif strcmpi(type,'range')
    m = dataset.meanData(1,end,:);
    plot(dataset.tData.tRange,m(:),'LineWidth',2)
    hold on
    grid on
    xlabel('Downrange (km)')
    ylabel('Propagation Factor Mean')
    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')
end