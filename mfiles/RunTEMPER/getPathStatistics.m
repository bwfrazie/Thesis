function fData = getPathStatistics(dataPath,varargin)

ignoreFiles = [];
if nargin == 2
    d = varargin{1};
    for i = 1:length(d)
        ignoreFiles{i} = sprintf('run_%d',d(i));
    end
end

tAlt = 1:.1:30;
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
fValues = zeros(length(fileList),length(tAlt),length(tRange));
%loop over the list and read the data
for counter = 1:length(fileList)
    fprintf('Loading file %d of %d\n',counter,length(fileList));
    fileName = sprintf('%s/%s',dataPath,fileList{counter});
    Out = tdata31(fileName,1,1,0);
    [xx,yy] = meshgrid(Out.r,Out.h);
    [xq,yq] = meshgrid(tRange,tAlt);
    interpData = interp2(xx,yy,Out.f,xq,yq);
    for aCounter = 1:length(tAlt)
        for rCounter = 1:length(tRange)
            fValues(counter,aCounter,rCounter) = interpData(aCounter,rCounter); 
        end
    end
     fValues(fValues <= 0 ) = 1e-8; 
end

fData.fValues = fValues;
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
