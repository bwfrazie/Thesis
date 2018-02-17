import os
import sys
from utilityFunctions import *
from multiprocessing import Process, Queue

						    
#main function          
def main():

	inputXMLFile = 'configuration.xml'
	nCores = 3
	
	nargs = len(sys.argv) - 1;
	
	if nargs > 0:
		inputXMLFile = sys.argv[1]
	if nargs > 1:
		nCores = sys.argv[2]
		
	srfInputFilename = "surfaceinput.srf";
	inputFilename = "base_input.in"	

	L,N,U10,age = getSeaSurfaceConfiguration(inputXMLFile)
	H,seed,nIter = getComputationConfiguration(inputXMLFile)
	setupRunFolder(inputFilename,srfInputFilename,"testFolder")
	s = setupSeeds(nCores, seed)
	start,stop = divideIterationsPerProcess(nCores,nIter)
	
	filePrefix = str(int(U10)) + "mps"
	
	print "Initializing Processes ..."
	
	proc = [ Process() for i in range(nCores)]
	
	for i in range (0,nCores):
		proc[i] = Process(target = runTEMPERProcess, args = (L,N,U10,age,H,s[i], filePrefix, inputFilename,srfInputFilename,start[i],stop[i],i+1))
		proc[i].start()
	

if __name__ == "__main__": main()

