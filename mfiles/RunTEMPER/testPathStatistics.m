datapath{1} = 'python/data_10mps_unfiltered';
datapath{2} = 'python/data_10mps_filtered_25';
datapath{3} = 'python/data_10mps_filtered_50';
datapath{4} = 'python/data_10mps_filtered_75';
datapath{5} = 'python/data_10mps_filtered_25_1_sided';
datapath{6} = 'python/data_10mps_filtered_50_1_sided';

basefileName = 'TEMPER_Inputs/anchor_10m_s.fld';
data = tdata31(basefileName,1,1,0);

varData = [];
meanData = [];


for i = 1:length(datapath)
    dispstring = sprintf('Parsing directory %d of %d',i,length(datapath));
    disp(dispstring);
    tData = getPathStatistics(datapath{i});
    varData(i,:,:) = var(tData.fAvg,0,1);
    meanData(i,:,:) = mean(tData.fAvg,1);
end


rInd = find(abs(data.r - tData.tRange(end)) < 0.00025);
aInd = find(abs(data.h - tData.tAlt(end)) < 0.025);

for i = 1:length(tData.tAlt)
    baseAlt(i) = interpolate2DData(data.f,data.h,data.r,tData.tAlt(i),tData.tRange(end));
end

for i = 1:length(tData.tAlt)
    baseRange(i) = interpolate2DData(data.f,data.h,data.r,tData.tAlt(end),tData.tRange(i));
end

plotPathStatistics(tData,varData,meanData);
