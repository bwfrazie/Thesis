function fData = getAltStatistics(dataPath,range,alt)
%get the list of field files
searchString = sprintf('%s/*.fld',dataPath);
fileVector = dir(searchString);
nFiles = size(fileVector,1);

fCounter = 1;
for counter = 1:nFiles
        fileList{fCounter} = fileVector(counter).name;
        fCounter = fCounter + 1;
end


dataCounter = 1;
fData = [];

%loop over the list and read the data
for counter = 1:length(fileList)
    fprintf('Loading file %d of %d\n',counter,length(fileList));
    fileName = sprintf('%s/%s',dataPath,fileList{counter});
    Out = tdata31(fileName,1,1,0);
    rIndex = find(Out.r == range);
    value = Out.f(:,rIndex);
    fData = [fData value];
end

end
