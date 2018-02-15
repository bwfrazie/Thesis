import os
import sys
import random
import numpy as np
from shutil import copyfile
from subprocess import call
from generateSeaSurface import generateSeaSurface

#this function updates the OSG random seed
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

#this function handles writing out the new surface file
#Currently, the main input file is not modified and always looks for the same file name
#Need to write the surfaces out twice - once for the file used by TEMPER, and once for a
#file that is updated so that we have a record of the generated surfaces
def updateSurfaceFile(srfName,newSrfName,x,h):
	copyfile(srfName,newSrfName);
	srfFile = open(srfName,'a')
	srfFile2 = open(newSrfName,'a')
	srfFile.write("\n")
	for i in range(0,len(x)):
		srfString = str(x[i]/1000) + "  " + str(h[i]) + "    0 0 0\n"
		srfFile.write(srfString)
		srfFile2.write(srfString)
		
	srfFile.close()
	srfFile2.close()

#main function          
def main():

#setup default parameters
	numIterations = 25;
	L = 10000;
	N = 20000;
	U10 = 10;
	age = 0.84;
	initialSeed = 561894;
	
	nargs = len(sys.argv) - 1;
	
	if nargs > 0:
		L = int(sys.argv[1]);
	if nargs > 1:
		N = int(sys.argv[2]);
	if nargs > 2:
		U10 = float(sys.argv[3])
	if nargs > 3:
		age = float(sys.argv[4])
	if nargs > 4:
		numIterations = int(sys.argv[5])
	if nargs > 5:
		initialSeed = long(sys.argv[6])
		
	printString = "Settings: \nL = " + str(L) + "\nN = " + str(N) + "\nU10 = " + str(U10) + "\nage = " + str(age) + "\nnumIterations = " + str(numIterations) + "\ninitialSeed = " + str(initialSeed) + "\n"
	
	print printString
	
	#initialize the random number generator
	np.random.seed(initialSeed);

	inputFolder = "../TEMPER_Inputs"
	dataFolder = "data"
	datapath = os.getcwd() + "/" + dataFolder
	dataDir = os.path.dirname(datapath)
	if not os.path.exists(dataDir):
		os.mkdir(dataDir)

	#call(["ls", "../TEMPER_Inputs/"])
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
	    newSrfName = filePrefix + "_run_" + str(runNumber) + ".srf"
	    updateSurfaceFile(srfInputFileName,newSrfName,x,h)
	    pString = "Run " + str(runNumber) + " of " + str(numIterations)
	    print pString
	    
	    newFilename = filePrefix + "_run_" + str(runNumber) + ".in"
	    print newFilename
	    copyfile(inputFilename,newFilename);
	    #newSeed = int(initialSeed * random.random())
	   # check(inputFilename,newFilename,newSeed)
	    call([temper,newFilename,"-b", "-q"])
	
	#end loop
if __name__ == "__main__": main()

