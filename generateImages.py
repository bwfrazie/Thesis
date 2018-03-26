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

os.chdir('..')
call(["cp", "src/path_contour.tex","build/path_contour.tex"])
os.chdir('build')
call(["pdflatex", "-shell-escape","path_contour.tex"])

while os.path.isfile('path_contour-figure0.pdf') == False:
	print('Waiting ...')
	pass
	
call(["cp", "path_contour-figure0.pdf", "../media/path_contour-figure0.pdf"])
