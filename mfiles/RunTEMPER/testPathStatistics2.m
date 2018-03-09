filepath = '/Volumes/Data/Thesis_Data/poster_data/';

datapath{1} = 'data_10mps_unfiltered';
datapath{2} = 'data_10mps_filtered_08';
datapath{3} = 'data_10mps_filtered_25';
datapath{4} = 'data_10mps_filtered_50';
datapath{5} = 'data_10mps_filtered_75';

basefileName = strcat(filepath,'anchor_10m_s.fld');
data = tdata31(basefileName,1,1,0);

varData = [];
meanData = [];

for i = 1:length(datapath)
    dispstring = sprintf('Parsing directory %d of %d',i,length(datapath));
    disp(dispstring);
    tData = getPathStatistics(strcat(filepath,datapath{i}));
    varData(i,:,:) = var(tData.fValues,0,1);
    meanData(i,:,:) = mean(tData.fValues,1);
end


rInd = find(abs(data.r - tData.tRange(end)) < 0.00025);
aInd = find(abs(data.h - tData.tAlt(end)) < 0.025);

for i = 1:length(tData.tAlt)
    baseAlt(i) = interpolate2DData(data.f,data.h,data.r,tData.tAlt(i),tData.tRange(end));
end

for i = 1:length(tData.tRange)
    baseRange(i) = interpolate2DData(data.f,data.h,data.r,tData.tAlt(end),tData.tRange(i));
end

plotPathStatistics2(tData,varData,meanData);
testPlotData(tData,meanData,varData);