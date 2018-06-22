filepath = '/Volumes/Data/Thesis_Data/stdatm_data/';

name{1} = 'data_10mps_18deg';
datainfo{1} = '10mps, std atm, 18 deg direction';

name{2} = 'data_10mps_36deg';
datainfo{2} = '10mps, std atm, 36 deg direction';

name{3} = 'data_10mps_54deg';
datainfo{3} = '10mps, std atm, 54 deg direction';

name{4} = 'data_10mps_72deg';
datainfo{4} = '10mps, std atm, 72 deg direction';

name{5} = 'data_10mps_90deg';
datainfo{5} = '10mps, std atm, 90 deg direction';

name{6} = 'data_10mps_0deg';
datainfo{6} = '10mps, std atm, 0 deg direction';

name{7} = 'data_05mps_0deg';
datainfo{7} = '05mps, std atm, 0 deg direction';

name{8} = 'data_08mps_0deg';
datainfo{8} = '08mps, std atm, 0 deg direction';

name{9} = 'data_12mps_0deg';
datainfo{9} = '12mps, std atm, 0 deg direction';

name{10} = 'data_15mps_0deg';
datainfo{10} = '15mps, std atm, 0 deg direction';

for i = 1:length(name)
    datapath{i} = strcat(filepath,'/',name{i});
end

for i = 1:1%length(datapath)
    dataset = [];
    
    dispstring = sprintf('Parsing directory %d of %d',i,length(datapath));
    disp(dispstring);
    
    dataset.info = datainfo{i};
    dataset.tData = getPathStatistics(datapath{i});
    dataset.varData = var(dataset.tData.fValues,0,1);
    dataset.rmsData = std(dataset.tData.fValues,0,1);
    dataset.meanData= mean(dataset.tData.fValues,1);
    
    close all
    disp('Fitting statistics')
    for a = 1:length(dataset.tData.tAlt)
        dispstring = sprintf('Fitting Altitude Row %d (%0.1f m) of %d elements',a,dataset.tData.tAlt(a),length(dataset.tData.tAlt));
        disp(dispstring);
        for r = 1:length(dataset.tData.tRange)
            d = dataset.tData.fValues(:,a,r);
            d(d<=0) = 1e-8;
            [dataset.sigma(a,r), dataset.v(a,r), dataset.alpha(a,r)] = statisticFitting2(d(:),dataset.tData.tRange,dataset.tData.tAlt,dataset.tData.tRange(r),dataset.tData.tAlt(a),0);
        end
    end
    
    cmdstring = sprintf('save %s dataset',string(datapath{i}));
    eval(cmdstring);
    
    plotPathStatistics3(dataset.tData.tAlt,dataset.tData.tRange,dataset.varData,dataset.meanData,dataset.rmsData);
    
    
end

