# Setup of WRF on Macbook arm64 using homebrew

## Step 1: Download homebrew

Navigate to the website [`brew.sh`](http:www.brew.sh) and follow the instructions.

You may want to add the following line to your `$HOME/.login`:
```tcsh
setenv PATH /opt/homebrew/bin:${PATH}
```
Then your `brew` knows where to look.

## Step 2: Download dependencies

Now you can use the following to set up your environment for WRF:

```tcsh
brew install gcc
brew install zlib
brew install hdf5
brew install netcdf
brew install netcdf-fortran
brew install libomp
brew install libpthread-stubs
brew install open-mpi
```
## Step 3: Download and install WRF

Now navigate to `${HOME}/Documents/WRF`.

```tcsh
mkdir ${HOME}/Documents/WRF
cd ${HOME}/Documents/WRF
# The following can also be part of your $HOME/.login
setenv NETCDF4 1
setenv NETCDF /opt/homebrew

git clone --recurse-submodule https://github.com/wrf-model/WRF.git
cd ${HOME}/Documents/WRF/WRF

# Configure with DM+SM par gfortran/gcc options
./configure
# Now edit configure.wrf:
vi configure.wrf
```

You will want to edit the following variables and make sure to link to the correct places inside `/opt/homebrew`.
```tcsh
...
HDF5            = -L/opt/homebrew/Cellar/hdf5/1.14.5/lib -lhdf5_hl -lhdf5
ZLIB            = -L/opt/homebrew/Cellar/zlib/1.3.1/lib -lz
NETCDF4_DEP_LIB = -L/opt/homebrew/Cellar/netcdf/4.9.2_2/lib -lnetcdf -L/opt/homebrew/Cellar/netcdf-fortran/4.6.1_1/lib -lnetcdff
...
 LIB_EXTERNAL    = \
                      -L$(WRF_SRC_ROOT_DIR)/external/io_netcdf -lwrfio_nf -L/opt/homebrew/lib -lnetcdff -lnetcdf -L/opt/homebrew/opt/libomp/lib -lomp
...
# Make sure, that "gfortran/gcc-14 --version" and "which gfortran/gcc-14" refer the correct executables, then use:
SFC             =       gfortran -I/opt/homebrew/opt/libomp/include -I/opt/homebrew/opt/zlib/include -I/opt/homebrew/include
SCC             =       gcc-14 -I/opt/homebrew/opt/libomp/include -I/opt/homebrew/opt/zlib/include -I/opt/homebrew/include
CCOMP           =       gcc-14 -I/opt/homebrew/opt/libomp/include -I/opt/homebrew/opt/zlib/include -I/opt/homebrew/include
DM_FC           =       /opt/homebrew/bin/mpif90
DM_CC           =       /opt/homebrew/bin/mpicc
...
CPP             =      cpp-14 -P -nostdinc -xassembler-with-cpp
```
With these, you can then hopefully `./compile -j 8`, which worked for me.

## Step 4: Download and install WPS

To obtain the source, repeat the trick from above.

```tcsh
cd $HOME/Documents/WRF
git clone --recurse-submodule https://github.com/wrf-model/WPS.git
cd ${HOME}/Documents/WRF/WPS
```

Since Version 4.3 or so, the amazing WRF Team built in a configure flag to install the all-so-tricky grib2 libraries needed together with WPS.

```tcsh
# Configure with Serial gfortran/gcc options
./configure --build-grib2-libs
# Now edit configure.wps:
vi configure.wps
```
Here, again, we need to add certain detail to make sure, clang does not ruin our fun...

```tcsh
...
WRF_INCLUDE     =       -I$(WRF_DIR)/external/io_netcdf \
                        -I$(WRF_DIR)/external/io_grib_share \
                        -I$(WRF_DIR)/external/io_grib1 \
                        -I$(WRF_DIR)/external/io_int \
                        -I$(WRF_DIR)/inc \
                        -I$(NETCDF)/include \
                        -I/opt/homebrew/opt/libomp/include

WRF_LIB         =       -L$(WRF_DIR)/external/io_grib1 -lio_grib1 \
                        -L$(WRF_DIR)/external/io_grib_share -lio_grib_share \
                        -L$(WRF_DIR)/external/io_int -lwrfio_int \
                        -L$(WRF_DIR)/external/io_netcdf -lwrfio_nf \
                        -L$(NETCDF)/lib -lnetcdff -lnetcdf \
                        -L/opt/homebrew/opt/libomp/lib -lomp
...
SFC                 = gfortran
SCC                 = gcc-14
DM_FC               = /opt/homebrew/bin/mpif90
DM_CC               = /opt/homebrew/bin/mpicc
...
CPP                 = cpp-14 -P -traditional
...
```
We need to include and link to `libomp` mostly because we compiled WRF with it, to avoid conflict.

With these settings I was able to successfully `./compile`, and all 3 executables were created.

```
./geogrid.exe
...
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  Successful completion of geogrid.        !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

./ungrib.exe
 *** Starting program ungrib.exe ***
...
 *** Found more than 10 consecutive bad GRIB records
 *** Let's just stop now.


 Perhaps the analysis file should have been converted
 from COS-Blocked format?

# :D
```

Have fun!
