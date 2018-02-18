function [sVar,sStd,sMax,sMin, sMean] = getSurfaceStatistics(datapath,varargin)

dString = sprintf('%s/*.srf',datapath);
fileVector = dir(dString);
nFiles = size(fileVector,1);

varVec = [];
meanVec = [];
minVec = [];
maxVec = [];

for i = 1:nFiles
    
    fname = sprintf('%s/%s',datapath,fileVector(i).name);
   if ~checkForIgnoreFile(fname)
       dispstring = sprintf('Loading file %d of %d',i,nFiles);
       disp(dispstring)
       
       temp = importdata(fname);

       %look at the 2nd column
        varVec = [varVec var(temp.data(:,2))];
        meanVec = [meanVec mean(temp.data(:,2))];
        maxVec = [maxVec max(temp.data(:,2))];
        minVec = [minVec min(temp.data(:,2))];
   end
        
end

sVar = varVec;%mean(varVec);
sStd = sqrt(sVar);
sMean = mean(meanVec);
sMax = mean(maxVec);
sMin = mean(minVec);


end

function b = checkForIgnoreFile(fname)

 b = false;
    
    if ~isempty(strfind(fname,'surfaceinput.srf'))
             b = true;
             dispString = sprintf('ignoring file %s',fname);
             disp(dispString)
     end
 end