%function getStatisticsFromFieldFiles(varargin)
dataPath = pwd;

tAlt = [5 10 15 18];
tRange = [5 10 15 20];

%go to the dataPath directory
cd(dataPath);

%get the list of field files
fileVector = ls('*.fld');
ind = strfind(fileVector,'.fld');

%loop through the list and separate the individual files
start = 1;
fileList = [];
startIndex = strfind(fileVector,'20km');
stopIndex = ind + 3;
for counter = 1:length(ind)
    start = startIndex(counter);
    stop = stopIndex(counter);
    fileList{counter} = fileVector(start:stop);
end

dataCounter = 1;

%loop over the list and read the data
for counter = 1:length(fileList)
    dispstring = sprintf('Loading file %d of %d',counter,length(fileList));
    disp(dispstring);
    Out = tdata31(fileList{counter},1,1,0);
     dataCounter = 1;
    for aCounter = 1:length(tAlt)
        for rCounter = 1:length(tRange)
            fAvg(counter,dataCounter) = interpolate2DData(Out.f,Out.h,Out.r,tAlt(aCounter),tRange(rCounter));
            dataCounter = dataCounter + 1;

        end
    end
    
end
