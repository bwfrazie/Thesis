%function getStatisticsFromFieldFiles(varargin)
dataPath = 'data';

tAlt = [5 10 15 20];
tRange = [10 15 20];

%go to the dataPath directory
cd(dataPath);

%get the list of field files
fileVector = ls('*.fld');
ind = strfind(fileVector,'.fld');

%loop through the list and separate the individual files
start = 1;
fileList = [];
for counter = 1:length(ind)
    stop = ind(counter) + 3;
    fileList{counter} = fileVector(start:stop);
    start = stop + 2;
end

dataCounter = 1;

%loop over the list and read the data
for counter = 1:1
    dispstring = sprintf('Loading file %d of %d',counter,length(fileList));
    disp(dispstring);
    Out = tdata31(fileList{counter},1,1,0);
    
    for aCounter = 1:length(tAlt)
        for rCounter = 1:length(tRange)
            rInd = find(abs(Out.r - tRange(rCounter)) < 0.05E-3);
            aInd = find(abs(Out.h - tAlt(aCounter)) < 0.05);
            
            fdBAvg(counter,dataCounter) = 0.5*(Out.fdb(aInd(1),rInd) + Out.fdb(aInd(2),rInd));
            dataCounter = dataCounter + 1;

        end
    end
    
end
