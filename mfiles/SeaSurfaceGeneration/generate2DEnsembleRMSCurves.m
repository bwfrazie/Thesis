function generate2DEnsembleRMSCurves(saveFigs,rmsMatrix,rmsXMatrix,rmsYMatrix,U10,L,alpha)

h(1) = figure;

subplot(1,3,1)
    lstring = [];
    [nn,mm] = size(rmsMatrix);
    for counter = 1:mm
        plot(U10,rmsMatrix(:,counter),'LineWidth',2);
        lstring{counter} = sprintf('L=%dkm, N=%dL',L(counter)/1000,alpha(counter));
        hold on
    end
    title('Total RMS')
    legend(lstring,'Location','NorthWest');
    grid on;
    xlabel('Wind Speed at 10 m Altitude (m/s)');
    ylabel('\sigma_h (m)')

    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')

    
    subplot(1,3,2)
    lstring = [];
    [nn,mm] = size(rmsXMatrix);
    for counter = 1:mm
        plot(U10,rmsXMatrix(:,counter),'LineWidth',2);
        lstring{counter} = sprintf('L=%dkm, N=%dL',L(counter)/1000,alpha(counter));
        hold on
    end
    title('RMS in X')
    legend(lstring,'Location','NorthWest');
    grid on;
    xlabel('Wind Speed at 10 m Altitude (m/s)');
    ylabel('\sigma_h (m)')

    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')

    
    subplot(1,3,3)
    lstring = [];
    [nn,mm] = size(rmsYMatrix);
    for counter = 1:mm
        plot(U10,rmsYMatrix(:,counter),'LineWidth',2);
        lstring{counter} = sprintf('L=%dkm, N=%dL',L(counter)/1000,alpha(counter));
        hold on
    end
    title('RMS in Y')
    legend(lstring,'Location','NorthWest');

    grid on;
    xlabel('Wind Speed at 10 m Altitude (m/s)');
    ylabel('\sigma_h (m)')

    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')
    
 %%   
    h(2) = figure
    [nn,mm] = size(rmsMatrix);
    for counter = 1:mm
        plot(U10,rmsMatrix(:,counter),'LineWidth',2);
        lstring{counter} = sprintf('L=%dkm, N=%dL',L(counter)/1000,alpha(counter));
        hold on
    end
      for counter = 1:mm
        plot(U10,rmsXMatrix(:,counter),'LineWidth',2);
        lstring{counter} = sprintf('L=%dkm, N=%dL',L(counter)/1000,alpha(counter));
        hold on
      end
       for counter = 1:mm
        plot(U10,rmsYMatrix(:,counter),'LineWidth',2);
        lstring{counter} = sprintf('L=%dkm, N=%dL',L(counter)/1000,alpha(counter));
        hold on
       end
    
           grid on;
    xlabel('Wind Speed at 10 m Altitude (m/s)');
    ylabel('\sigma_h (m)')

    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    set(gca,'FontWeight','bold')
    
%%
if(saveFigs == 1)
    saveas(h(1),'2d_ensemble_separate_rms','png')
    saveas(h(2),'2d_ensemble_rms','png')
end