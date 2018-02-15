import os
import random
from shutil import copyfile
from subprocess import call

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

            
def main():
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

	inputFilename = "base_20km_1d_10m_s.in"
	src = inputFolder + "/" + inputFilename
	dst = dataFolder + "/"  + inputFilename
	copyfile(src,dst);

	os.chdir("data")
	
	#start loop
	for runNumber in range(2,502):
		newFilename = filePrefix + "_run_" + str(runNumber) + ".in"
	
		newSeed = int(initialSeed * random.random())
		check(inputFilename,newFilename,newSeed)

		call([temper,newFilename])
	
	#end loop
if __name__ == "__main__": main()

