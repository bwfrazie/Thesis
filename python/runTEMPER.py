import os
import sys
import random
import re
import numpy as np
from shutil import copyfile
from subprocess import call
from generateSeaSurface import generateSeaSurface
from multiprocessing import Process, Queue

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
def updateSurfaceFile(srfName,newSrfName,x,h,inputFilename,newFilename):
	copyfile(srfName,newSrfName);
	srfFile = open(newSrfName,'a')
	srfFile.write("\n")
	for i in range(0,len(x)):
		srfString = str(x[i]/1000) + "  " + str(h[i]) + "    0 0 0\n"
		srfFile.write(srfString)
	srfFile.close()
	
	oldfile = open(inputFilename,'r')
	newfile = open(newFilename,'w')
	testLine = "Surface param file (200 char max) (ter type 1,2,3; surf type 3; rough surf 2):"
	newLine = newSrfName + "\n"
	updateLine = False
	for line in oldfile:
		if testLine in line:
			newfile.write(line)
			updateLine = True
		elif updateLine == True:
			updateLine = False;
			newfile.write(newLine)
		else:
			newfile.write(line)
	

def runProcess(L,N,U10,age,filePrefix,start,stop,inputFilename,srfInputFileName,initialSeed,id):
	#initialize the random number generator
	np.random.seed(initialSeed);
	#temper = "/Users/benjaminfrazier/Projects/TEMPER/temper/bin/mac64/temper.bin"
	temper = "/Users/frazibw1/APL/TEMPER/temper/bin/mac64/temper.bin"
	numIterations = stop - start
	for runNumber in range(start,stop):
		newFilename = filePrefix + "_run_" + str(runNumber) + ".in"
		copyfile(inputFilename,newFilename);
		h,x = generateSeaSurface(L, N, U10, age,0)
		newSrfName = filePrefix + "_run_" + str(runNumber) + ".srf"
		updateSurfaceFile(srfInputFileName,newSrfName,x,h,inputFilename,newFilename)
		pString = "Process " + str(id) + " Run " + str(runNumber + 1 - start) + " of " + str(numIterations)
		print pString
		call([temper,newFilename,"-b", "-q"])
	    #newSeed = int(initialSeed * random.random())
	    #check(inputFilename,newFilename,newSeed)	    

def computeAngles(tx,tgt,rx1,rx2,d1,d2,d3):
	theta1 = np.arctan2(tgt[2] - tx[2],tgt[1] - tx[1])
	N2 = 2*d2
	N3 = 2*d3
	theta2 = np.zeros(N2)
	theta3 = np.zeros(N3)
	
	path2 = rx1 - tgt
	v2 = path2/np.linalg.norm(path2)
	for i in range(0,N2):
		p2 = tgt + i*0.5*v2
		theta2[i] = np.arctan2(p2[2] - tx[2],p2[1] - tx[1]);

	
	path3 = rx2 - tgt;
	v3 = path3/np.linalg.norm(path3);
	for i in range(0,N3):
		p3 = tgt + i*0.5*v3
		theta3[i] = np.arctan2(p3[2] - tx[2],p3[1] - tx[1]);
    
	return theta1,theta2,theta3
		    
#main function          
def main():

#setup default parameters
	numIterations = 100;
	L = 20000;
	N = 40000;
	U10 = 10;
	age = 0.84;
	
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
		
	printString = "Settings: \nL = " + str(L) + "\nN = " + str(N) + "\nU10 = " + str(U10) + "\nage = " + str(age) + "\nnumIterations = " + str(numIterations) + "\n"
	
	print printString
	
	tx = np.array([0, 0, 50]);
	tgt = np.array([24000, -2000, 30]);
	rx1 = np.array([16000, 9000, 10]);
	rx2 = np.array([26000, 8000, 10]);
	d1 = 25000
	d2 = 15000
	d3 = 15000
	
	theta1,theta2,theta3 = computeAngles(tx,tgt,rx1,rx2,d1,d2,d3)

	inputFolder = "../TEMPER_Inputs"
	dataFolder = "data"
	datapath = os.getcwd() + "/" + dataFolder
	dataDir = os.path.dirname(datapath)
	if not os.path.exists(dataDir):
		os.mkdir(dataDir)

	#call(["ls", "../TEMPER_Inputs/"])
	dst = os.getcwd()
	filePrefix = "20km_1d_5mps"

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
	
	#set up the multiple processes
	nPerProcess = int(numIterations/3);
	start1 = 0;
	stop1 = nPerProcess;
	start2 = stop1;
	stop2 = start2 + nPerProcess;
	start3 = stop2;
	stop3 = numIterations;
	
	seed1 = 561894;
	seed2 = 785623
	seed3 = 452352
	#start loop
	p1 = Process(target = runProcess, args =(L,N,U10,age,filePrefix,start1,stop1,inputFilename,srfInputFileName,seed1,1));
	p2 = Process(target = runProcess, args =(L,N,U10,age,filePrefix,start2,stop2,inputFilename,srfInputFileName,seed2,2));
	p3 = Process(target = runProcess, args =(L,N,U10,age,filePrefix,start3,stop3,inputFilename,srfInputFileName,seed3,3));
	
	p1.start()
	p2.start()
	p3.start()
	
	
	#end loop
if __name__ == "__main__": main()

