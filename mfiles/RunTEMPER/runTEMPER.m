function runTEMPER(varargin)

%set the path to TEMPER and the current path
temper = '/Users/frazibw1/APL/TEMPER/temper/bin/mac64/temper.bin';
%temper = '/Users/benjaminfrazier/Projects/TEMPER/temper/bin/mac64/temper.bin';
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
        error('Cannot find TEMPER_Inputs directory');
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
%only needed if testing with TEMPER's OSG mode
% wsInputFileName = sprintf('%s/TEMPER_Inputs/%s',inputPath,'osgInputFile.osgin');
% copyfile(wsInputFileName,currentPath);

%surfacefile
srfInputFileName = sprintf('%s/TEMPER_Inputs/%s',inputPath,'surfaceinput.srf');

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

numIterations = 50;
L = 10000;
N = 20000;
U10 = 10;
age = 0.84;

rng(initialSeed)

%loop over the requested number of iterations
for runNumber = 1:numIterations
    dispstring = sprintf('Run %d of %d ...',runNumber,numIterations);
    disp(dispstring);
    %get the sea surface;
    [h,~, ~, ~, x, ~, ~] = generateSeaSurface(L, N, U10, age);
    
    %write out the surface data
    copyfile(srfInputFileName,currentPath);
    fid = fopen('surfaceinput.srf','a');
    srfName = sprintf('%s_run%d.srf',filePrefix,runNumber);
    copyfile('surfaceinput.srf',srfName);
    fid1 = fopen(srfName);
    fprintf(fid,'\n');
    
    for i = 1:length(h)
        %need range in km and altitude in m
        fprintf(fid,'%f %f 0 0 0\n',x(i)/1000,h(i));
        fprintf(fid1,'%f %f 0 0 0\n',x(i)/1000,h(i));
    end
    fclose(fid);
    fclose(fid1);

    %create the new input file
    inputFileName = sprintf('%s_run%d.in',filePrefix,runNumber);
    copyfile(baseFileName,inputFileName);
    
    %get the new seed and update the file
    %only needed if testing with TEMPER's OSG mode
%     newSeed = round(initialSeed*rand(1));
%     getset_temper_input(inputFileName,'set','osgSeed',newSeed);

    %set the command string and run the TEMPER case
    commandString = sprintf('%s %s -b -q',temper, inputFileName);
    system(commandString);
end