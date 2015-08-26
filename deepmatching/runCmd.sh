#mex -v -c conv.cpp *.o  -ljpeg -lpng CXXFLAGS=' -fopenmp -fPIC' LDFLAGS='/usr/lib/atlas-base/libsatlas.so' -lgomp
#mex -v -c deep_matching.cpp *.o  -ljpeg -lpng CXXFLAGS=' -fopenmp -fPIC' LDFLAGS='/usr/lib/atlas-base/libsatlas.so' -lgomp
#bash mexCmd
mex -v -c conv.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fopenmp -fPIC' -lgomp 
mex -v -c deep_matching.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fopenmp -fPIC' -lgomp 
mex -v deepmex.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fopenmp -fPIC' -lgomp
#/usr/local/MATLAB/R2014a/bin/matlab -nodesktop -nosplash -r debugmex 
