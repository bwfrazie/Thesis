filepath = '/Volumes/Data/Thesis_Data/10GHz_data/';

datapath{1} = 'data_10mps';
datapath{2} = 'data_5mps';


basefileName1 = strcat(filepath,'anchor_10m_s.fld');
data1 = tdata31(basefileName1,1,1,0);
basefileName2 = strcat(filepath,'anchor_5m_s.fld');
data2 = tdata31(basefileName2,1,1,0);

varData = [];
meanData = [];

for i = 1:length(datapath)
    dispstring = sprintf('Parsing directory %d of %d',i,length(datapath));
    disp(dispstring);
    tData = getPathStatistics(strcat(filepath,datapath{i}));
    rmsData(i,:,:) = rms(tData.fValues,0,1);
    varData(i,:,:) = var(tData.fValues,0,1);
    meanData(i,:,:) = mean(tData.fValues,1);
end

tRange = tData.tRange;
tAlt = tData.tAlt;

rInd1 = find(abs(data1.r - tData.tRange(end)) < 0.00025);
aInd1 = find(abs(data1.h - tData.tAlt(end)) < 0.025);
rInd2 = find(abs(data2.r - tData.tRange(end)) < 0.00025);
aInd2 = find(abs(data2.h - tData.tAlt(end)) < 0.025);

[xx1,yy1] = meshgrid(data1.r,data1.h);
[xx2,yy2] = meshgrid(data1.r,data1.h);
[xq,yq] = meshgrid(tData.tRange,tData.tAlt);
baseData1 = interp2(xx1,yy1,data1.f,xq,yq);
baseData2 = interp2(xx2,yy2,data1.f,xq,yq);

save ThesisDataFile.mat rmsData varData meanData baseData1 baseData2 data1 data2 tRange tAlt