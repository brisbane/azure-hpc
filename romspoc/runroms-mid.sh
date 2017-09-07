#!/bin/bash -x
#PBS -lnodes=30:ppn=16

if ! [ -e /opt/intel/compilers_and_libraries_2017.4.196 ]; then
    sudo ln -s /data/software/intel/compilers_and_libraries_2017.4.196 /opt/intel/compilers_and_libraries_2017.4.196
fi

# For a SLES 12 SP1 HPC cluster

#source /opt/intel/impi/5.0.3.048/bin64/mpivars.sh

# For a CentOS-based HPC cluster

source /opt/intel/impi/2017.2.174/bin64/mpivars.sh

source /opt/intel/compilers_and_libraries_2017.4.196/linux/bin/ifortvars.sh intel64
source /opt/intel/compilers_and_libraries_2017.4.196/linux/bin/iccvars.sh intel64

export I_MPI_FABRICS=shm:dapl

# THIS IS A MANDATORY ENVIRONMENT VARIABLE AND MUST BE SET BEFORE RUNNING ANY JOB
# Setting the variable to shm:dapl gives best performance for some applications
# If your application doesn’t take advantage of shared memory and MPI together, then set only dapl

export I_MPI_DAPL_PROVIDER=ofa-v2-ib0

# THIS IS A MANDATORY ENVIRONMENT VARIABLE AND MUST BE SET BEFORE RUNNING ANY JOB

export I_MPI_DYNAMIC_CONNECTION=0

# THIS IS A MANDATORY ENVIRONMENT VARIABLE AND MUST BE SET BEFORE RUNNING ANY JOB

NP=$(cat $PBS_NODEFILE | wc -l)

# Command line to run the job
cd /data/software/ne_atlantic

export LD_LIBRARY_PATH="/data/software/hdf5/1.10.1/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/data/software/zlib/1.2.11/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/data/software/netcdf-single/lib:$LD_LIBRARY_PATH"

mpirun -np $NP -machinefile $PBS_NODEFILE  -env I_MPI_FABRICS=dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 ./oceanM Data/INPUT/ne_atl_HC_3.6_15120.in

