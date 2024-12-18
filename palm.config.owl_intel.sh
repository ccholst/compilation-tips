################################################################################
# This is a configuration file for PALM. It must be named: .palm.config.<suffix>
# in order to use it, call palmbuild and palmrun with the option: -h <suffix>
# Documentation: https://palm.muk.uni-hannover.de/trac/wiki/doc/app/jobcontrol
################################################################################
#
#-------------------------------------------------------------------------------
# General compiler and host configuration section.
# Variable declaration lines must start with a percent character
# Internal variables can be used as {{VARIABLE_NAME}}. Please see documentation.
#-------------------------------------------------------------------------------
%base_directory      /bg/home/holst-c/palm-4u/24-04/RUN
%base_data           /bg/home/holst-c/
%source_path         /bg/home/holst-c/palm-4u/24-04/packages/palm/model/src
%user_source_path    /bg/data/urbclim/holst-c/PALM_JOBS/${run_identifier}/USER_CODE
%fast_io_catalog     /bg/data/urbclim/holst-c/PALM_JOBS/${run_identifier}/TMP
%restart_data_path   /bg/data/urbclim/holst-c/PALM_JOBS/${run_identifier}/RESTART
%output_data_path    /bg/data/urbclim/holst-c/PALM_JOBS
%local_jobcatalog    /bg/data/urbclim/holst-c/PALM_JOBS/${run_identifier}/LOGS
#%remote_jobcatalog   <path/to/directory>
#
%local_ip            127.0.0.1
#%local_ip            172.27.90.111
%local_hostname      owl01amd
%local_username      holst-c
#
#
%defaultqueue        milan
%submit_command      /usr/bin/sbatch
#
%compiler_name       /app/spack/0.19.0/opt/spack/linux-almalinux9-x86_64/oneapi-2022.2.1/intel-oneapi-mpi-2021.7.1-ji2yquks4566dgix4xbviadghx2w2l5x/mpi/2021.7.1/bin/mpiifort

%compiler_name_ser   /app/spack/0.19.0/opt/spack/linux-almalinux9-x86_64_v3/gcc-11.3.1/intel-oneapi-compilers-2022.2.1-uej6arag2ppvghbkzkkhxjoilqgb2ddo/compiler/2022.2.1/linux/bin/ifx

%cpp_options         -cpp -D__intel -D__parallel -DMPI_REAL=MPI_DOUBLE_PRECISION -DMPI_2REAL=MPI_2DOUBLE_PRECISION -D__netcdf -D__netcdf4 -D__netcdf_parallel -D__rrtmg

%make_options        -j 4

%compiler_options    -fpp -O3 -fp-model precise -fno-alias -ftz -no-prec-div -no-prec-sqrt -ipo -nbs -diag-disable 8290,8291 -I${NETCDF_FORTRAN_ROOT}/include -I${NETCDF_C_ROOT}/include -I${PARALLEL_NETCDF_ROOT}/include -I${HDF5_ROOT}/include -I${I_MPI_ROOT}/include -I${RRTMG_ROOT}/include

%linker_options     -fpp -O3 -fp-model precise -fno-alias -ftz -no-prec-div -no-prec-sqrt -ipo -nbs -diag-disable 8290,8291 -L${NETCDF_FORTRAN_ROOT}/lib -lnetcdff -L${NETCDF_C_ROOT}/lib -lnetcdf -L${PARALLEL_NETCDF_ROOT}/lib -lpnetcdf -L${HDF5_ROOT}/lib -lhdf5 -lhdf5_hl -lhdf5_tools -L${I_MPI_ROOT}/lib -lmpi -lmpifort -L${I_MPI_PMI_LIBRARY} -L${RRTMG_ROOT}/lib -lrrtmg

%execute_command      /usr/bin/srun --propagate=STACK --kill-on-bad-exit -n {{mpi_tasks}} -N {{nodes}} --ntasks-per-node={{tasks_per_node}}  palm
%execute_command_for_combine  /usr/bin/srun --propagate=STACK -n 1 --ntasks-per-node=1  combine_plot_fields.x

%memory              2300

#%module_commands     module switch craype-ivybridge craype-haswell; module load fftw cray-hdf5-parallel cray-netcdf-hdf5parallel
#%login_init_cmd      .execute_special_profile
#
#-------------------------------------------------------------------------------
# Directives to be used for batch jobs
# Lines must start with "BD:". If $-characters are required, hide them with \
# Internal variables can be used as {{variable_name}}. Please see documentation.
#-------------------------------------------------------------------------------
BD:#!/bin/bash
#BD:#PBS -A {{project_account}}
BD:#PBS -N {{run_id}}
BD:#PBS -l walltime={{cpu_hours}}:{{cpu_minutes}}:{{cpu_seconds}}
BD:#PBS -l nodes={{nodes}}:ppn={{tasks_per_node}}
BD:#PBS -o {{job_protocol_file}}
BD:#PBS -j oe
BD:#PBS -q {{queue}}
#
#-------------------------------------------------------------------------------
# Directives for batch jobs used to send back the jobfiles from a remote to a local host
# Lines must start with "BDT:". If $-characters are required, excape them with triple backslash
# Internal variables can be used as {{variable_name}}. Please see documentation.
#-------------------------------------------------------------------------------
BDT:#!/bin/bash
#BDT:#PBS -A {{project_account}}
BDT:#PBS -N job_protocol_transfer
BDT:#PBS -l walltime=00:30:00
BDT:#PBS -l nodes=1:ppn=1
BDT:#PBS -o {{job_transfer_protocol_file}}
BDT:#PBS -j oe
BDT:#PBS -q dataq
#
#-------------------------------------------------------------------------------
# INPUT-commands. These commands are executed before running PALM
# Lines must start with "IC:"
#-------------------------------------------------------------------------------
IC:ulimit  -s unlimited
#
#-------------------------------------------------------------------------------
# ERROR-commands. These commands are executed when PALM terminates abnormally
# Lines must start with "EC:"
#-------------------------------------------------------------------------------
EC:[[ $locat = execution ]]  &&  cat  RUN_CONTROL
#
#-------------------------------------------------------------------------------
# OUTPUT-commands. These commands are executed when PALM terminates normally
# Lines must start with "OC:"
#-------------------------------------------------------------------------------
#
# Combine 1D- and 3D-profile output (these files are not usable for plotting)
OC:[[ -f LIST_PROFIL_1D     ]]  &&  cat  LIST_PROFIL_1D  >>  LIST_PROFILE
OC:[[ -f LIST_PROFIL        ]]  &&  cat  LIST_PROFIL     >>  LIST_PROFILE
#
# Combine all particle information files
OC:[[ -f PARTICLE_INFOS/_0000 ]]  &&  cat  PARTICLE_INFOS/* >> PARTICLE_INFO
