import time

temp_env=Environment()
env=Environment(tools=['default','pdflatex'],ENV=temp_env['ENV'])
env.Append(PDFLATEXFLAGS=['-halt-on-error','-shell-escape'])
Export('env')

doc = SConscript('src/SConscript',variant_dir='build')
Install('dist',doc)

tgf = SConscript('src/SConscriptGF',variant_dir='build')
Install('dist',tgf)

tsp = SConscript('src/SConscriptSP',variant_dir='build')
Install('dist',tsp)

os1 = SConscript('src/SConscriptOS',variant_dir='build')
Install('dist',os1)
