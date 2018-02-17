import os
import numpy as np
import xml.etree.ElementTree
import random
from shutil import copyfile
from subprocess import call
from generateSeaSurface import generateSeaSurface

#getSeaSurfaceConfiguration - returns the spatial domain length, number of points and wind
#speed from a configuration file
def getSeaSurfaceConfiguration(inputXMLFile):
	#get the root
	root = xml.etree.ElementTree.parse(inputXMLFile).getroot()
	srf = root.find('seaSurface')
	
	#get the parameters
	dx = float(srf.find('dx').text)
	L = float(srf.find('L').text)
	U10 = float(srf.find('U10').text)
	age = float(srf.find('age').text)
	
	#compute N
	N = int(L/dx)
	
	return L,N,U10,age

#getComputationConfiguration - returns the antenna height, initial seed and number of
#iterations from a configuration file
def getComputationConfiguration(inputXMLFile):
	#get the root
	root = xml.etree.ElementTree.parse(inputXMLFile).getroot()
	comp = root.find('computation')
	
	#get the parameters
	H = float(comp.find('H').text)
	seed = int(comp.find('seed').text)
	nIter = int(comp.find('nIterations').text)

	return H,seed,nIter

#updateSurfaceFile - this function handles writing out the new surface file
def updateSurfaceFile(srfName,newSrfName,x,h):
	copyfile(srfName,newSrfName);
	srfFile = open(newSrfName,'a')
	srfFile.write("\n")
	for i in range(0,len(x)):
		srfString = str(x[i]/1000) + "  " + str(h[i]) + "    0 0 0\n"
		srfFile.write(srfString)
	srfFile.close()


#updateTEMPERInputFile - creates a new input file and updates the computed range, antenna height, and surface file
def updateTEMPERInputFile(baseFilename,newFilename,newSrfname, L, H):
	#open the new file and the original file
	inputFile = open(newFilename,'w')
	baseFile = open(baseFilename,'r')

	#identify the lines to look for and the updated lines to change them to
	testLine1 = "Antenna height [ft|m]"
	testLine2 = "Maximum problem range [nmi|km]"
	testLine3 = "Surface param file (200 char max) (ter type 1,2,3; surf type 3; rough surf 2):"
	newLine1 = str(H) + "          " + testLine1 + '\r'
	newLine2 = str(L/1000) + "          " + testLine2 + '\r'
	newLine3 = newSrfname + "\r"
	
	#loop over the old file and write to the new file with either the old line or the new line
	updateLine = False
	for line in baseFile:
		if testLine1 in line:
			inputFile.write(newLine1)
		elif testLine2 in line:
			inputFile.write(newLine2)
		elif testLine3 in line:
			updateLine = True
			inputFile.write(line)
		elif updateLine == True:
			updateLine = False
			inputFile.write(newLine3)
		else:
			inputFile.write(line)
			
	#make sure to close the files
	inputFile.close()
	baseFile.close() 

def setupSeeds(nCores, initialSeed):
	s = np.zeros(nCores,'int')
	
	for i in range(0,nCores):
		s[i] = int(np.floor(0.5*initialSeed + (3*initialSeed)*np.random.rand(1)))
		
	return s

def divideIterationsPerProcess(nCores,nIterations):

	start = np.zeros(nCores,'int')
	stop = np.zeros(nCores,'int')
	nPerProcess = int(nIterations/float(nCores))
	
	s = 0
	
	for i in range(0,nCores):
		start[i] = s
		stop[i] = start[i] + nPerProcess
		s = stop[i]
		if i == nCores - 1:
			stop[i] = nIterations
	
	return start,stop


#setupRunFolder - this function copies necessary TEMPER input files to the "data" folder
def setupRunFolder(inputFilename,srfInputFileName,dataFolder):
	inputFolder = "../TEMPER_Inputs"
	datapath = os.getcwd() + "/" + dataFolder
	dataDir = os.path.dirname(datapath)
	if not os.path.exists(dataDir):
		os.mkdir(dataDir)

	fname = "Sector.pat"
	src = inputFolder + "/" + fname
	dst = dataFolder + "/"  + fname
	
	copyfile(src,dst);

	fname = "stdatm.ref"
	src = inputFolder + "/" + fname
	dst = dataFolder + "/"  + fname
	copyfile(src,dst);
	
	src = inputFolder + "/" + srfInputFileName
	dst = dataFolder + "/"  + srfInputFileName
	copyfile(src,dst);

	src = inputFolder + "/" + inputFilename
	dst = dataFolder + "/"  + inputFilename
	copyfile(src,dst);

	os.chdir(dataFolder)
	
def runTEMPERProcess(L,N,U10,age,H,seed, filePrefix, inputFilename,srfInputFileName,startIndex, stopIndex, id):
	#initialize the random number generator
	np.random.seed(seed);
	#temper = "/Users/benjaminfrazier/Projects/TEMPER/temper/bin/mac64/temper.bin"
	temper = "/Users/frazibw1/APL/TEMPER/temper/bin/mac64/temper.bin"
	numIterations = stopIndex - startIndex
	
	pStringPrefix = "Process " + str(id)
	
	for runNumber in range(startIndex,stopIndex ):
		pString = pStringPrefix + " Run " + str(runNumber + 1 - startIndex) + " of " + str(numIterations)
		print pString
		
		newFilename = filePrefix + "run_" + str(runNumber) + ".in"
		newSrfName = filePrefix + "run_" + str(runNumber) + ".srf"
		updateTEMPERInputFile(inputFilename,newFilename,newSrfName, L, H)
		pString = pStringPrefix + " Generating Surface ... "
		print pString
		h,x = generateSeaSurface(L, N, U10, age,0)
		
		updateSurfaceFile(srfInputFileName,newSrfName,x,h)
		pString = pStringPrefix + " Calling TEMPER ... "
		print pString
		call([temper,newFilename,"-b", "-q"])
