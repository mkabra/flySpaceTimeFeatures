#mex -v -c conv.cpp *.o  -ljpeg -lpng CXXFLAGS=' -fopenmp -fPIC' LDFLAGS='/usr/lib/atlas-base/libsatlas.so' -lgomp
#mex -v -c deep_matching.cpp *.o  -ljpeg -lpng CXXFLAGS=' -fopenmp -fPIC' LDFLAGS='/usr/lib/atlas-base/libsatlas.so' -lgomp
#bash mexCmd
#mex -v -c conv.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fopenmp -fPIC' -lgomp 
#mex -v -c deep_matching.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fopenmp -fPIC' -lgomp 
#mex -v deepmex.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fopenmp -fPIC' -lgomp
#without openmp
rm -rf *.o deepmex
mex -v -c hog.cpp -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
mex -v -c maxfilter.cpp -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
mex -v -c io.cpp -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
mex -v -c image.cpp -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
mex -v -c pixel_desc.cpp -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
mex -v -c conv.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
mex -v -c conv.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC'
mex -v -c deep_matching.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
mex -v deepmex.cpp *.o  -ljpeg -lpng -lmwblas -lmwlapack CXXFLAGS=' -fPIC' 
/usr/local/MATLAB/R2015a/bin/matlab -nodesktop -nosplash -r debugmex 
