# Configuration and Installation for Climate Data Operator (cdo) on MacOSX arm64

This is assuming that you have set up the environment as described in the WRF and WPS compilation instructions.

```tcsh
cd $WRF_DIR/..
wget https://code.mpimet.mpg.de/attachments/29649
tar -xvf cdo-2.4.4.tar.gz

cd cdo-2.4.4
mkdir build
```

So far for prepration.

Give configure all info it could possibly need. cdo is written in C++ and C, as far as I understand it. We also need a suitable preprocessor cpp. For me the following configuration call produced successful compilation:

```tcsh
./configure AR=/opt/homebrew/bin/gcc-ar-14 NM=/opt/homebrew/bin/gcc-nm-14 RANLIB=/opt/homebrew/bin/gcc-ranlib-14 CXX=/opt/homebrew/bin/g++-14 CC=/opt/homebrew/bin/gcc-14 CFLAGS=-O2 CPP=/opt/homebrew/bin/cpp-14 --with-netcdf=/opt/homebrew/opt/netcdf --with-hdf5=/opt/homebrew/opt/hdf5 --with-szlib=/opt/homebrew/opt/libaec --with-zlib=/opt/homebrew/opt/zlib --prefix=$PWD/build

make # This takes a while. You may add j=8 to speed up

make install prefix=$PWD/build
```

Good luck!
