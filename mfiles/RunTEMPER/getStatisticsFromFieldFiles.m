%function getStatisticsFromFieldFiles(varargin)
dataPath = 'data';

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

%loop over the list and read the data
for counter = 1:1
    Out = tdata31(fileList{counter},1,1,0);
end
