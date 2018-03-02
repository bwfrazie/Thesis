function fData = getPathStatistics(dataPath,varargin)

ignoreFiles = [];
if nargin == 2
    d = varargin{1};
    for i = 1:length(d)
        ignoreFiles{i} = sprintf('run_%d',d(i));
    end
end

tAlt = 1:.1:19;
tRange = 1:.1:20;


%get the list of field files
searchString = sprintf('%s/*.fld',dataPath);
fileVector = dir(searchString);
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
fAvg = zeros(length(fileList),length(tAlt),length(tRange));
%loop over the list and read the data
for counter = 1:length(fileList)
    dispstring = sprintf('Loading file %d of %d',counter,length(fileList));
    disp(dispstring)
    fileName = sprintf('%s/%s',dataPath,fileList{counter});
    Out = tdata31(fileName,1,1,0);
    for aCounter = 1:length(tAlt)
        for rCounter = 1:length(tRange)
            fAvg(counter,aCounter,rCounter) = interpolate2DData(Out.f,Out.h,Out.r,tAlt(aCounter),tRange(rCounter));
        end
    end
temp = 1;    
end

fData.fAvg = fAvg;
end

function b = checkForIgnoreFile(fname,ignoreFiles)

 b = false;
    
 if isempty(ignoreFiles)
     b = false;
 else
     for i = 1:size(ignoreFiles,2)
         if contains(fname,ignoreFiles{i})
             b = true;
             dispString = sprintf('ignoring file %s',fname);
             disp(dispString)
         end
     end
 end

     
end
