import os
import sys
import random
import re
import numpy as np
import xml.etree.ElementTree

from shutil import copyfile
from subprocess import call
from generateSeaSurface import generateSeaSurface
from multiprocessing import Process, Queue


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


class pathInfoClass:
	dx = 0.0
	age = 0.0
	U10 = 0.0
	p1Length = 0.0
	p1NPoints = 0
	p2Length = 0.0
	p2NPoints = 0
	p3Length = 0.0
	p3NPoints = 0
	tgt = np.zeros(3)
	tx = np.zeros(3)
	rx1 = np.zeros(3)
	rx2 = np.zeros(3)

class surfaceInfoClass:
	L = 0.0
	N = 0
	phi = 0.0
	age = 0.0
	U10 = 0.0
	dx = 0.0
	tx = 0.0
	antennaHeight = 0.0
	start = np.zeros(3)
	stop = np.zeros(3)
	filePrefix = ""

class processInfoClass:
	startIndex = 0
	stopIndex = 0
	seed = 0
	
def getPathAngles(srf,index):
	phi = np.zeros(srf.N/2+1)

	uv = (srf.stop - srf.start)/np.linalg.norm(srf.stop - srf.start)
	
	if index != 1:
		for i in range(0,srf.N/2+1):
			p = srf.start + i*srf.dx*uv
			phi[i] = np.arctan2(p[1] - srf.tx[1],p[0] - srf.tx[0])
	else:
		for i in range(0,srf.N/2+1):
			phi[i] = np.arctan2(srf.stop[1] - srf.tx[1],srf.stop[0] - srf.tx[0])

	return phi
	
def getSurfaceInfo(pathInfo):
	srf1 = surfaceInfoClass()
	srf1.dx = pathInfo.dx
	srf1.tx = pathInfo.tx
	srf1.L = pathInfo.p1Length
	srf1.N = pathInfo.p1NPoints
	srf1.age = pathInfo.age
	srf1.U10 = pathInfo.U10
	srf1.start = pathInfo.tx
	srf1.stop = pathInfo.tgt
	srf1.filePrefix = "Path1_" + str(srf1.U10) +"mps_"
	srf1.antennaHeight = pathInfo.tx[2]
	
	srf2 = surfaceInfoClass()
	srf2.dx = pathInfo.dx
	srf2.tx = pathInfo.tx
	srf2.L = pathInfo.p2Length
	srf2.N = pathInfo.p2NPoints
	srf2.age = pathInfo.age
	srf2.U10 = pathInfo.U10
	srf2.start = pathInfo.tgt
	srf2.stop = pathInfo.rx1
	srf2.filePrefix = "Path2_" + str(srf2.U10) +"mps_"
	srf2.antennaHeight = pathInfo.tgt[2]
	
	srf3 = surfaceInfoClass()
	srf3.dx = pathInfo.dx
	srf3.tx = pathInfo.tx
	srf3.L = pathInfo.p3Length
	srf3.N = pathInfo.p3NPoints
	srf3.age = pathInfo.age
	srf3.U10 = pathInfo.U10
	srf3.start = pathInfo.tgt
	srf3.stop = pathInfo.rx2
	srf3.filePrefix = "Path3_" + str(srf3.U10) +"mps_"
	srf3.antennaHeight = pathInfo.tgt[2]
	
	srf1.phi = getPathAngles(srf1,1)
	srf2.phi = getPathAngles(srf2,2)
	srf3.phi = getPathAngles(srf3,3)
	
	return srf1,srf2,srf3
        
def getGeometry(inputXMLFile):
	#get the root
	root = xml.etree.ElementTree.parse(inputXMLFile).getroot()
	geom = root.find('geometry')
	#get the tgt
	tgtXML = geom.find('target');
	tgtX = float(tgtXML.find('xValue').text);
	tgtY = float(tgtXML.find('yValue').text);
	tgtZ = float(tgtXML.find('zValue').text);
	tgt = np.array([tgtX, tgtY, tgtZ])
	#get the tx
	txXML = geom.find('tx');
	txX = float(txXML.find('xValue').text);
	txY = float(txXML.find('yValue').text);
	txZ = float(txXML.find('zValue').text);
	tx = np.array([txX, txY, txZ])
	#get the rx1
	rx1XML = geom.find('rx1');
	rx1X = float(rx1XML.find('xValue').text);
	rx1Y = float(rx1XML.find('yValue').text);
	rx1Z = float(rx1XML.find('zValue').text);
	rx1 = np.array([rx1X, rx1Y, rx1Z])
	#get the rx2
	rx2XML = geom.find('rx2');
	rx2X = float(rx2XML.find('xValue').text);
	rx2Y = float(rx2XML.find('yValue').text);
	rx2Z = float(rx2XML.find('zValue').text);
	rx2 = np.array([rx2X, rx2Y, rx2Z])
	
	return tgt,tx,rx1,rx2

def getPathInfo(inputXMLFile):
	pathInfo = pathInfoClass()
	#get the root
	root = xml.etree.ElementTree.parse(inputXMLFile).getroot()
	pathXML = root.find('pathInfo')
	#get the general settings
	genSettings = pathXML.find('general')
	pathInfo.dx = float(genSettings.find('deltaX').text)
	pathInfo.age = float(genSettings.find('age').text)
	pathInfo.U10 = float(genSettings.find('U10').text)
	
	#get the path 1 specific values
	p1 = pathXML.find('path1')
	pathInfo.p1Length = float(p1.find('L').text)
	pathInfo.p1NPoints = int(pathInfo.p1Length/pathInfo.dx)
	
	#get the path 2 specific values
	p2 = pathXML.find('path2')
	pathInfo.p2Length = float(p2.find('L').text)
	pathInfo.p2NPoints = int(pathInfo.p2Length/pathInfo.dx)
	
	#get the path 3 specific values
	p3 = pathXML.find('path3')
	pathInfo.p3Length = float(p3.find('L').text)
	pathInfo.p3NPoints = int(pathInfo.p3Length/pathInfo.dx)
	
	tgt,tx,rx1,rx2 = getGeometry(inputXMLFile)
	pathInfo.tgt = tgt
	pathInfo.tx = tx
	pathInfo.rx1 = rx1
	pathInfo.rx2 = rx2

	return pathInfo

def getProcessInfo(numIterations,initialSeed):
	
	s1 = int(0.5*initialSeed + (3*initialSeed)*np.random.rand(1))
	s2 = int(0.5*initialSeed + (3*initialSeed)*np.random.rand(1))
	s3 = int(0.5*initialSeed + (3*initialSeed)*np.random.rand(1))
	
	process1Info = processInfoClass()
	process2Info = processInfoClass()
	process3Info = processInfoClass()
	
	process1Info.startIndex = 0
	process1Info.stopIndex = numIterations
	process1Info.seed = s1
	
	process2Info.startIndex = 0
	process2Info.stopIndex = numIterations
	process2Info.seed = s2
	
	process3Info.startIndex = 0
	process3Info.stopIndex = numIterations
	process3Info.seed = s3
	
	return process1Info,process2Info,process3Info

def updateInputFile(baseFilename,newFilename,p):
	inputFile = open(newFilename,'w')
	baseFile = open(baseFilename,'r')

	testLine1 = "Antenna height [ft|m]"
	testLine2 = "Maximum problem range [nmi|km]"
	newLine1 = str(p.antennaHeight) + "          " + testLine1 + '\r'
	newLine2 = str(p.L/1000) + "          " + testLine2 + '\r'

	for line in baseFile:
		if testLine1 in line:
			inputFile.write(newLine1)
		elif testLine2 in line:
			inputFile.write(newLine2)
		else:
			inputFile.write(line)
	inputFile.close()
	baseFile.close() 
	
def generateStatistics(p, processInfo,inputFilename,srfInputFileName,id):
	#initialize the random number generator
	np.random.seed(processInfo.seed);
	#temper = "/Users/benjaminfrazier/Projects/TEMPER/temper/bin/mac64/temper.bin"
	temper = "/Users/frazibw1/APL/TEMPER/temper/bin/mac64/temper.bin"
	numIterations = processInfo.stopIndex - processInfo.startIndex
	
	pStringPrefix = "Process " + str(id)
	
	for runNumber in range(processInfo.startIndex,processInfo.stopIndex ):
		pString = pStringPrefix + " Run " + str(runNumber + 1 - processInfo.startIndex) + " of " + str(numIterations)
		print pString
		
		newFilename = p.filePrefix + "run_" + str(runNumber) + ".in"
		updateInputFile(inputFilename,newFilename,p)
		pString = pStringPrefix + " Generating Surface ... "
		print pString
		h,x = generateSeaSurface(p.L, p.N, p.U10, p.age,p.phi)
		newSrfName = p.filePrefix + "run_" + str(runNumber) + ".srf"
		
		updateSurfaceFile(srfInputFileName,newSrfName,x,h,inputFilename,newFilename)
		pString = pStringPrefix + " Calling TEMPER ... "
		print pString
		call([temper,newFilename,"-b", "-q"])

def setupRunFolder():
	inputFolder = "../TEMPER_Inputs"
	dataFolder = "data"
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
	
	srfInputFileName = "surfaceinput.srf";
	src = inputFolder + "/" + srfInputFileName
	dst = dataFolder + "/"  + srfInputFileName
	copyfile(src,dst);

	inputFilename = "base_input.in"
	src = inputFolder + "/" + inputFilename
	dst = dataFolder + "/"  + inputFilename
	copyfile(src,dst);

	os.chdir("data")
	
	return inputFilename,srfInputFileName
						    
#main function          
def main():

	inputXMLFile = 'configuration.xml'
	numIterations = 100
	initialSeed = 561894
	
	nargs = len(sys.argv) - 1;
	
	if nargs > 0:
		inputXMLFile = sys.argv[1]
	if nargs > 1:
		numIterations = int(sys.argv[2])
	if nargs > 2:
		initialSeed = int(sys.argv[3])

	print "Getting Path Info ..."
	pathInfo = getPathInfo(inputXMLFile)
	print "Getting Surface Info ..."
	p1,p2,p3 = getSurfaceInfo(pathInfo)
	print "Getting Process Info ..."
	process1Info,process2Info,process3Info = getProcessInfo(numIterations,initialSeed)
	print "Setting up Run Folder ..."
	inputFileName,srfInputFileName = setupRunFolder()
	
	print "Initializing Processes ..."
	proc1 = Process(target = generateStatistics, args =(p1,process1Info,inputFileName,srfInputFileName,1));
	proc2 = Process(target = generateStatistics, args =(p2,process2Info,inputFileName,srfInputFileName,2));
	proc3 = Process(target = generateStatistics, args =(p3,process3Info,inputFileName,srfInputFileName,3));
	
	proc1.start()
	proc2.start()
	proc3.start()
	

if __name__ == "__main__": main()

