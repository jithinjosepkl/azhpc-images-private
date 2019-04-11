#!/bin/bash
# Install communication runtimes and MPI libraries

set -ex

INSTALL_PREFIX=/opt

mkdir -p /tmp/mpi
cd /tmp/mpi

# MVAPICH2 2.3.1
wget http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-2.3.1.tar.gz
tar -xvf mvapich2-2.3.1.tar.gz
cd mvapich2-2.3.1
./configure --prefix=${INSTALL_PREFIX}/mvapich2-2.3.1 --enable-g=none --enable-fast=yes && make -j 8 && make install
cd ..

# UCX 1.5.1
wget https://github.com/openucx/ucx/releases/download/v1.5.1/ucx-1.5.1.tar.gz
tar -xvf ucx-1.5.1.tar.gz
cd ucx-1.5.1
./contrib/configure-release --prefix=${INSTALL_PREFIX}/ucx-1.5.1 && make -j 8 && make install
cd ..

# HPC-X v2.3.0
cd ${INSTALL_PREFIX}
wget http://www.mellanox.com/downloads/hpc/hpc-x/v2.3/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64.tbz
tar -xvf hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64.tbz
HPCX_PATH=${INSTALL_PREFIX}/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64
HCOLL_PATH=${HPCX_PATH}/hcoll
rm -rf hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64.tbz
cd /tmp/mpi

# OpenMPI 4.0.1
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.1.tar.gz
tar -xvf openmpi-4.0.1.tar.gz
cd openmpi-4.0.1
./configure --prefix=${INSTALL_PREFIX}/openmpi-4.0.1 --with-ucx=${INSTALL_PREFIX}/ucx-1.5.1 --enable-mpirun-prefix-by-default && make -j 8 && make install
cd ..

# MPICH 3.3
wget http://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz
tar -xvf mpich-3.3.tar.gz
cd mpich-3.3
./configure --prefix=${INSTALL_PREFIX}/mpich-3.3 --with-ucx=${INSTALL_PREFIX}/ucx-1.5.0 --with-hcoll=${HCOLL_PATH} --enable-g=none --enable-fast=yes --with-device=ch4:ucx   && make -j 8 && make install 
cd ..

# Intel MPI 2019 (update 3)
CFG="IntelMPI-v2019.x-silent.cfg"
wget http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15260/l_mpi_2019.3.199.tgz
wget https://raw.githubusercontent.com/szarkos/AzureBuildCentOS/master/config/azure/${CFG}
tar -xvf l_mpi_2019.3.199.tgz
cd l_mpi_2019.3.199
./install.sh --silent /tmp/mpi/${CFG}
cd ..

# Setup module files for MPIs
mkdir -p /usr/share/Modules/modulefiles/mpi/

# HPC-X
cat << EOF >> /usr/share/Modules/modulefiles/mpi/hpcx-v2.3.0
#%Module 1.0
#
#  HPCx 2.3.0
#
conflict        mpi
prepend-path    PATH            /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi/bin
prepend-path    PATH            /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64
prepend-path    LD_LIBRARY_PATH /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi/lib
prepend-path    MANPATH         /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi/share/man
setenv          MPI_BIN         /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi/bin
setenv          MPI_INCLUDE     /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi/include
setenv          MPI_LIB         /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi/lib
setenv          MPI_MAN         /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi/share/man
setenv          MPI_HOME        /opt/hpcx-v2.3.0-gcc-MLNX_OFED_LINUX-4.5-1.0.1.0-redhat7.6-x86_64/ompi
EOF

# MPICH
cat << EOF >> /usr/share/Modules/modulefiles/mpi/mpich-3.3
#%Module 1.0
#
#  MPICH 3.3
#
conflict        mpi
prepend-path    PATH            /opt/mpich-3.3/bin
prepend-path    LD_LIBRARY_PATH /opt/mpich-3.3/lib
prepend-path    MANPATH         /opt/mpich-3.3/share/man
setenv          MPI_BIN         /opt/mpich-3.3/bin
setenv          MPI_INCLUDE     /opt/mpich-3.3/include
setenv          MPI_LIB         /opt/mpich-3.3/lib
setenv          MPI_MAN         /opt/mpich-3.3/share/man
setenv          MPI_HOME        /opt/mpich-3.3
EOF

# MVAPICH2
cat << EOF >> /usr/share/Modules/modulefiles/mpi/mvapich2-2.3.1
#%Module 1.0
#
#  MVAPICH2 2.3
#
conflict        mpi
prepend-path    PATH            /opt/mvapich2-2.3.1/bin
prepend-path    LD_LIBRARY_PATH /opt/mvapich2-2.3.1/lib
prepend-path    MANPATH         /opt/mvapich2-2.3.1/share/man
setenv          MPI_BIN         /opt/mvapich2-2.3.1/bin
setenv          MPI_INCLUDE     /opt/mvapich2-2.3.1/include
setenv          MPI_LIB         /opt/mvapich2-2.3.1/lib
setenv          MPI_MAN         /opt/mvapich2-2.3.1/share/man
setenv          MPI_HOME        /opt/mvapich2-2.3.1
EOF

# OpenMPI
cat << EOF >> /usr/share/Modules/modulefiles/mpi/openmpi-4.0.1
#%Module 1.0
#
#  OpenMPI 4.0.1
#
conflict        mpi
prepend-path    PATH            /opt/openmpi-4.0.1/bin
prepend-path    LD_LIBRARY_PATH /opt/openmpi-4.0.1/lib
prepend-path    MANPATH         /opt/openmpi-4.0.1/share/man
setenv          MPI_BIN         /opt/openmpi-4.0.1/bin
setenv          MPI_INCLUDE     /opt/openmpi-4.0.1/include
setenv          MPI_LIB         /opt/openmpi-4.0.1/lib
setenv          MPI_MAN         /opt/openmpi-4.0.1/share/man
setenv          MPI_HOME        /opt/openmpi-4.0.1
EOF

#IntelMPI-v2019
cat << EOF >> /usr/share/Modules/modulefiles/mpi/impi-2019.3.199
#%Module 1.0
#
#  Intel MPI 2019.3.199
#
conflict        mpi
prepend-path    PATH            /opt/intel/impi/2019.3.199/intel64/bin
prepend-path    LD_LIBRARY_PATH /opt/intel/impi/2019.3.199/intel64/lib
prepend-path    MANPATH         /opt/intel/impi/2019.3.199/man
setenv          MPI_BIN         /opt/intel/impi/2019.3.199/intel64/bin
setenv          MPI_INCLUDE     /opt/intel/impi/2019.3.199/intel64/include
setenv          MPI_LIB         /opt/intel/impi/2019.3.199/intel64/lib
setenv          MPI_MAN         /opt/intel/impi/2019.3.199/man
setenv          MPI_HOME        /opt/intel/impi/2019.3.199/intel64
EOF

cd && rm -rf /tmp/mpi
