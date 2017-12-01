function runTEMPER()

%set the path to TEMPER and the current path
temper = '/Users/frazibw1/APL/TEMPER/temper/bin/mac64/temper.bin';
temper = '/Users/benjaminfrazier/Projects/TEMPER/temper/bin/mac64/temper.bin';
currentPath = pwd;

%get the base path for the Input files
token = 'TEMPER_Inputs';
counter = 0;
status = 0;
while(~status)
    cd('..');
    status = isdir(token);
    counter = counter + 1;
    
    if(counter > 4)
        status = 1;
        error('Cannot find TEMPER_Inputs file');
    end
end

%set the input path and go back to the initial directory
inputPath = pwd;
cd(currentPath);

%make a local "data" directory and go to it
mkdir('data');
cd('data');

%update the current path
currentPath = pwd;

%handle copying the input files - need the base input and OSG files
wsInputFileName = sprintf('%s/TEMPER_Inputs/%s',inputPath,'osgInputFile.osgin');
copyfile(wsInputFileName,currentPath);

%antenna pattern file
patInputFileName = sprintf('%s/TEMPER_Inputs/%s',inputPath,'Sector.pat');
copyfile(patInputFileName,currentPath);

%refractivity file
refInputFileName = sprintf('%s/TEMPER_Inputs/%s',inputPath,'stdatm.ref');
copyfile(refInputFileName,currentPath);


baseFileName = sprintf('%s/TEMPER_Inputs/%s',inputPath,'base_20km_1d_10m_s.in');

%setup the file prefix and the initial seed
filePrefix = '20km_1d_10mps';
initialSeed = 561894;

numIterations = 100;

%loop over the requested number of iterations
for runNumber = 1:numIterations

    %create the new input file
    inputFileName = sprintf('%s_run%d.in',filePrefix,runNumber);
    copyfile(baseFileName,inputFileName);

    %get the new seed and update the file
    newSeed = round(initialSeed*rand(1));
    getset_temper_input(inputFileName,'set','osgSeed',newSeed);

    %set the command string and run the TEMPER case
    commandString = sprintf('%s %s',temper, inputFileName);
    system(commandString);
end