function fData = getStatisticsFromFieldFiles(varargin)

ignoreFiles = [];
if nargin == 1
    d = varargin{1};
    ignoreFiles{1} = sprintf('run_%d',d(1));
    ignoreFiles{2} = sprintf('run_%d',d(2));
    ignoreFiles{3} = sprintf('run_%d',d(3));
end

dataPath = pwd;


tAlt = [5 10 15 18];
tRange = [5 10 15 20];

%go to the dataPath directory
cd(dataPath);

%get the list of field files
fileVector = dir('*.fld');
nFiles = size(fileVector,1);

fCounter = 1;
for counter = 1:nFiles
    if ~checkForIgnoreFile(fileVector(counter).name,ignoreFiles)
        fileList{fCounter} = fileVector(counter).name;
        fCounter = fCounter + 1;
    end
end


dataCounter = 1;

fData.tRange = tRange;
fData.tAlt = tAlt;
%loop over the list and read the data
for counter = 1:length(fileList)
    dispstring = sprintf('Loading file %d of %d',counter,length(fileList));
    disp(dispstring)
    Out = tdata31(fileList{counter},1,1,0);
     dataCounter = 1;
    for aCounter = 1:length(tAlt)
        for rCounter = 1:length(tRange)
            fAvg(counter,dataCounter) = interpolate2DData(Out.f,Out.h,Out.r,tAlt(aCounter),tRange(rCounter));
            dataCounter = dataCounter + 1;

        end
    end
    
end

fData.fAvg = fAvg;
end

function b = checkForIgnoreFile(fname,ignoreFiles)

 b = false;
    
 if isempty(ignoreFiles)
     b = false;
 else
     for i = 1:size(ignoreFiles,2)
         if ~isempty(strfind(fname,ignoreFiles{i}))
             b = true;
             dispString = sprintf('ignoring file %s',fname);
             disp(dispString)
         end
     end
 end

     
end
