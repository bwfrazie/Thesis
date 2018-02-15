import os
import random
from shutil import copyfile
from subprocess import call
from generateSeaSurface import generateSeaSurface

def check(oldname,newname,newSeed):
    oldfile = open(oldname,'r')
    newfile = open(newname,'w')
    testLine = "OSG realization random seed (integer)"
    for line in oldfile:
        if testLine in line:
            newstring = str(newSeed) + "   " + testLine + "\n"
            newfile.write(newstring)
        else:
        	newfile.write(line)

def updateSurfaceFile(srfName,x,h):
	srfFile = open(srfName,'a')
	for i in range(0,len(x)):
		srfString = str(x[i]/1000) + "  " + str(h[i]) + "    0 0 0\n"
		srfFile.write(srfString)
            
def main():

	numIterations = 1;
	L = 10000;
	N = 20000;
	U10 = 10;
	age = 0.84;

	inputFolder = "../TEMPER_Inputs"
	dataFolder = "data"
	datapath = os.getcwd() + "/" + dataFolder
	dataDir = os.path.dirname(datapath)
	if not os.path.exists(dataDir):
		os.mkdir(dataDir)

	call(["ls", "../TEMPER_Inputs/"])
	dst = os.getcwd()
	filePrefix = "20km_1d_5mps"

	initialSeed = 56182189;
	#temper = "/Users/benjaminfrazier/Projects/TEMPER/temper/bin/mac64/temper.bin"
	temper = "/Users/frazibw1/APL/TEMPER/temper/bin/mac64/temper.bin"

	fname = "osgInputFile5.osgin"
	src = inputFolder + "/" + fname
	dst = dataFolder + "/"  + "osgInputFile.osgin"
	copyfile(src,dst);

	fname = "Sector.pat"
	src = inputFolder + "/" + fname
	dst = dataFolder + "/"  + fname
	copyfile(src,dst);

	fname = "stdatm.ref"
	src = inputFolder + "/" + fname
	dst = dataFolder + "/"  + fname
	copyfile(src,dst);
	
	srfInputFileName = "surfaceinput.srf";
	src = inputFolder + "/" + srfInputFileName
	dst = dataFolder + "/"  + srfInputFileName
	copyfile(src,dst);

	inputFilename = "base_20km_1d_10m_s.in"
	src = inputFolder + "/" + inputFilename
	dst = dataFolder + "/"  + inputFilename
	copyfile(src,dst);

	os.chdir("data")
	
	#start loop
	for runNumber in range(0,numIterations):
	
	    h,x = generateSeaSurface(L, N, U10, age)
	    updateSurfaceFile(srfInputFileName,x,h)
	    
	    newFilename = filePrefix + "_run_" + str(runNumber) + ".in"
	    
	    newSeed = int(initialSeed * random.random())
	    check(inputFilename,newFilename,newSeed)
	    call([temper,newFilename])
	
	#end loop
if __name__ == "__main__": main()

