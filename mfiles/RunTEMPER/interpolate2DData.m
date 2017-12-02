function [outValue] = interpolate2DData(data,rData,cData,rReq,cReq)


%find the indices to use in the data
rInd = find(rData >= rReq,1);
cInd = find(cData >= cReq,1);

if (isempty(rInd) || isempty(cInd))
    error("Requested element not found");
end

%check to see if either value is equal

%set up gains for the 4 elements
g1 = abs(rReq - rData(rInd))/(abs(rData(rInd) - rData(rInd-1)));
g2 = abs(rReq - rData(rInd-1))/(abs(rData(rInd) - rData(rInd-1)));
g3 = abs(cReq - cData(cInd))/(abs(cData(cInd) - cData(cInd-1)));
g4 = abs(cReq - cData(cInd-1))/(abs(cData(cInd) - cData(cInd-1)));

outValue = g3*(g1*data(rInd-1,cInd-1) + g2*data(rInd,cInd-1)) + g4*(g1*data(rInd-1,cInd) + g2*data(rInd,cInd));