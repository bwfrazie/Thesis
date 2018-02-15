from generateSeaSurface import *

import h5py

h = generateSeaSurface()

print"ok"
print(h[50])
#save data to hdf5 file
file = h5py.File('test.h5','w')


file.create_group("surface");

dset = file.create_dataset("h", data = h);

file.close();