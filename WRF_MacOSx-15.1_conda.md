# Setup for WRF compilation on Macbook M1 arm64 architecture

## Step 1: Apple Developer Command Line Tools

NOT SURE IF REALLY NEEDED, except for libSystem.tbd

Download CLT from Apple
```tcsh
# Remove any old version
sudo rm -rf /Library/Developer/CommandLineTools
# Install newest version
sudo xcode-select --install
```
That takes a while...

## Step 2: conda package manager for dependencies

```tcsh
conda create -n WRF
conda activate WRF
conda install gfortran zlib libpng jasper openmpi hdf5 openlibm
conda install netcdf4 netcdf-fortran
```

All those dependencies now live in `/opt/anaconda3/envs/WRF`

```tcsh
setenv DIR_PKG /opt/anaconda3/envs/WRF
```

## Step 3: Environment setup for compilers

```tcsh
# executables
setenv PATH ${DIR_PKG}/bin:${PATH}
# headers
setenv CPATH ${DIR_PKG}/include
# libraries
setenv LIBRARY_PATH ${DIR_PKG}/lib
setenv DYLD_LIBRARY_PATH ${DIR_PKG}/lib
setenv LD_LIBRARY_PATH ${DIR_PKG}/lib
# compilers
alias gc /opt/anaconda3/envs/WRF/bin/arm64-apple-darwin20.0.0-clang
alias gcp /opt/anaconda3/envs/WRF/bin/arm64-apple-darwin20.0.0-clang-cpp
alias gf /opt/anaconda3/envs/WRF/bin/arm64-apple-darwin20.0.0-gfortran
alias mgf "gf -I${NETCDF}/include -L${NETCDF}/lib -lmpi_usempif08 -lmpi_usempi_ignore_tkr -lmpi_mpifh -lmpi"
alias mgc "gc -I${NETCDF}/include -L${NETCDF}/lib -lmpi_usempif08 -lmpi_usempi_ignore_tkr -lmpi_mpifh -lmpi -Wno-unused-command-line-argument"
```

`LD_LIBRARY_PATH` to my knowledge instructs the linker in preprocessing step (cpp). For WRF this is usually required.

To make sure that the libraries can be linked and found correctly, manually link libSystem and libm into the library directory.

```tcsh
cd /opt/anaconda3/envs/WRF/lib
# System lib
ls /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib/libSystem*
ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib/libSystem.tbd libSystem.tbd
ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib/libSystem_asan.tbd libSystem_asan.tbd
# math lib
ls /opt/anaconda3/envs/WRF/lib/libopenlibm.*
ln -s opt/anaconda3/envs/WRF/lib/libopenlibm.4.0.dylib libm.4.0.dylib
ln -s opt/anaconda3/envs/WRF/lib/libopenlibm.4.dylib libm.4.dylib
ln -s opt/anaconda3/envs/WRF/lib/libopenlibm.dylib libm.dylib
cd -
```

## Step 4: Create WRF's new home and specific environment variables

```tcsh
mkdir ${HOME}/Documents/WRF
setenv NETCDF4 1
setenv NETCDF $DIR_PKG
setenv JASPERLIB $DIR_PKG/lib
setenv JASPERINC $DIR_PKG/include
```

## Step 5: Test compilers

```tcsh
mkdir $HOME/Documents/WRF/pre-compile
cd $HOME/Documents/WRF/pre-compile
wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xvf Fortran_C_tests.tar

gf TEST_1_fortran_only_fixed.f
./a.out

gf TEST_2_fortran_only_free.f90
./a.out

gc TEST_3_c_only.c
./a.out

gc -c TEST_4_fortran+c_c.c
gf -c TEST_4_fortran+c_f.f90
gf TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
./a.out
```

These 4 tests should print SUCCESS messages on the terminal.

```tcsh
./TEST_csh.csh
./TEST_perl.pl
./TEST_sh.sh
```

These 3 tests should print SUCCESS messages as well.

## Step 6: Test the libararies

Now the fun part...
```tcsh
wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
tar -xvf Fortran_C_NETCDF_MPI_tests.tar
cp ${NETCDF}/include/netcdf.inc .

gf -c -I${NETCDF}/include 01_fortran+c+netcdf_f.f
gc -c -I${NETCDF}/include 01_fortran+c+netcdf_c.c
gf -L${NETCDF}/lib -lnetcdff -lnetcdf -I${NETCDF}/include 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o
./a.out

mgf -c 02_fortran+c+netcdf+mpi_f.f
mgc -c 02_fortran+c+netcdf+mpi_c.c
mgf -L${NETCDF}/lib -lnetcdf -lnetcdff 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o
mpirun -n 2 ./a.out
```

Success! Great!

## Step 6: Install WRF
```tcsh
git clone --recurse-submodule https://github.com/wrf-model/WRF.git
cd ${HOME}/Documents/WRF/WRF
./configure
# Option 22: gfortran+clang (sm+dmpar) and your preferred nesting option
# Edit the configure.wrf to make sure your compilers, compiler-flags and environment settings are correct. See below.
./compile em_real -j 8 > log_compilation.log
```

The compilers need to be set correctly, the aliases will not work correctly here.

```bash
SFC                 = /opt/anaconda3/envs/WRF/bin/arm64-apple-darwin20.0.0-gfortran
SCC                 = /opt/anaconda3/envs/WRF/bin/arm64-apple-darwin20.0.0-clang
DM_FC               = .....
DM_CC               = .....
...
CPP                 = /opt/anaconda3/envs/WRF/bin/arm64-apple-darwin20.0.0-clang-cpp -P -traditional
```
The same applies to WPS in the next step.

With these compiler settings, on my MacBookPro M1 Pro it compiled successfully.

## Step 7: Install WPS

> [!WARNING]
> This is not working due to architecture conflicts in the compilers. I need another solution for this, as fixing is not feasible. Already spent 5 nights on this now.

```tcsh
setenv WRF_DIR ${HOME}/Documents/WRF/WRF
git clone https://github.com/wrf-model/WPS.git
cd ${HOME}/Documents/WRF/WPS
./configure
# Option 22
# You need to add -lomp in your config libraries, otherwise it will not work.
#
./compile > log_compilation.log
```

# Acknowledgement

Figuring these environment settings and preparatory steps out took me a while, and I would like to express my thanks to the WRF team and community for their amazing documentation, as well as the amazing expert communities on stack exchange, reddit, Intel - and Apple developer forums.
This little guide is a consolidation of small tips and nuggets I harvested from all those sources.
