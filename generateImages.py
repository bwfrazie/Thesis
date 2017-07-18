from subprocess import call
import os

call(["cp", "src/hankel_contours.tex","build/hankel_contours.tex"])
os.chdir('build')
call(["pdflatex", "-shell-escape","hankel_contours.tex"])

while os.path.isfile('hankel_contours-figure0.pdf') == False:
	print('Waiting ...')
	pass
	
call(["cp", "hankel_contours-figure0.pdf", "../media/hankel_contours-figure0.pdf"])
call(["cp", "hankel_contours-figure1.pdf", "../media/hankel_contours-figure1.pdf"])

