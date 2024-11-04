#wget https://github.com/hpc/mpifileutils/releases/download/v0.11.1/mpifileutils-v0.11.1.tgz
#tar -zxf mpifileutils-v0.11.1.tgz
cd mpifileutils-v0.11.1
  mkdir build
  cd build
    cmake -DCMAKE_C_COMPILER=/opt/cray/pe/gcc/12.2.0/snos/bin/gcc \
	-DCMAKE_CXX_COMPILER=/opt/cray/pe/gcc/12.2.0/snos/bin/g++ \
      -DWITH_LibArchive_PREFIX=../../install \
      -DCMAKE_INSTALL_PREFIX=../../install \
	-DCMAKE_INCLUDE_PATH=/usr/lib64/lustre/tests \
	-DCMAKE_LIBRARY_PATH=/usr/lib64/lustre/tests \
	-DENABLE_XATTRS=OFF \
	-DENABLE_LUSTRE=ON ..
    make -j install
  cd ..
cd ..
