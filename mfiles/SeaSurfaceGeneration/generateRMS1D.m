function [rmsMatrix, U10, Lresults, alpharesults] = generateRMS1D(varargin)

saveFigs = 0;

if(nargin == 1)
    saveFigs = varargin{1};
end

M = 100;
age = 0.84;

L = [1000 10000];
alpha = [2 10 100];
U10 = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
index = 1;

Lresults = [];
alpharesults = [];
varVec = [];
rmsMatrix = [];
for Lcounter = 1:length(L)
    dispstring = sprintf('Processing L = %d m, number %d of %d',L(Lcounter), Lcounter,length(L));
    disp(dispstring);
    for(alphaCounter = 1:length(alpha))
        N = alpha(alphaCounter)*L(Lcounter);
        dispstring = sprintf('Processing N = %dL, number %d of %d',alpha(alphaCounter), alphaCounter,length(alpha));
        disp(dispstring);
        for (uCounter = 1:length(U10))
            dispstring = sprintf('Processing U10 = %d m/s, number %d of %d',U10(uCounter), uCounter,length(U10));
            disp(dispstring);
            totalRMS = 0;
            varVec = [];
            for counter = 1:M
                if(mod(counter,10) == 0)
                    dispstring = sprintf('Creating Surface %d of %d',counter,M);
                    disp(dispstring);
                end

                %generate the surface
                [h, ~, ~, ~] = generateSeaSurface(L(Lcounter), N, U10(uCounter), age);
                
                varVec = [varVec var(h)];
                totalRMS = sqrt(mean(varVec));
            end
            rmsMatrix(uCounter,index) = totalRMS;
        end
        alpharesults(index) = alpha(alphaCounter);
        Lresults(index) = L(Lcounter);
        index = index + 1;
    end
end

generateEnsembleRMSCurves(saveFigs,rmsMatrix,U10,Lresults,alpharesults)
end

