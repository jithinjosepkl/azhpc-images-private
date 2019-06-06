#!/bin/bash
# Install communication runtimes and MPI libraries

set -ex

# Install MPIs
INSTALL_PREFIX=/opt
mkdir -p /tmp/mpi
cd /tmp/mpi

# MVAPICH2 2.3.1
MV2_VERSION="2.3.1"
wget http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-${MV2_VERSION}.tar.gz
tar -xvf mvapich2-${MV2_VERSION}.tar.gz
cd mvapich2-${MV2_VERSION}
./configure --prefix=${INSTALL_PREFIX}/mvapich2-${MV2_VERSION} --enable-g=none --enable-fast=yes && make -j 8 && make install
cd ..

# UCX 1.5.1
UCX_VERSION=1.5.1
wget https://github.com/openucx/ucx/releases/download/v${UCX_VERSION}/ucx-${UCX_VERSION}.tar.gz
tar -xvf ucx-${UCX_VERSION}.tar.gz
cd ucx-${UCX_VERSION}
./contrib/configure-release --prefix=${INSTALL_PREFIX}/ucx-${UCX_VERSION} && make -j 8 && make install
cd ..

# HPC-X v2.4.1
HPCX_VERSION="v2.4.1"
cd ${INSTALL_PREFIX}
wget ftp://bgate.mellanox.com/uploads/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64.tbz
tar -xvf hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64.tbz
HPCX_PATH=${INSTALL_PREFIX}/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64
HCOLL_PATH=${HPCX_PATH}/hcoll
rm -rf hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64.tbz
cd /tmp/mpi

# OpenMPI 4.0.1
OMPI_VERSION="4.0.1"
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-${OMPI_VERSION}.tar.gz
tar -xvf openmpi-${OMPI_VERSION}.tar.gz
cd openmpi-${OMPI_VERSION}
./configure --prefix=${INSTALL_PREFIX}/openmpi-${OMPI_VERSION} --with-ucx=${INSTALL_PREFIX}/ucx-${UCX_VERSION} --with-hcoll=${HCOLL_PATH} --enable-mpirun-prefix-by-default && make -j 8 && make install
cd ..

# MPICH 3.3
MPICH_VERSION="3.3"
wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz
tar -xvf mpich-${MPICH_VERSION}.tar.gz
cd mpich-${MPICH_VERSION}
./configure --prefix=${INSTALL_PREFIX}/mpich-${MPICH_VERSION} --with-ucx=${INSTALL_PREFIX}/ucx-${UCX_VERSION} --with-hcoll=${HCOLL_PATH} --enable-g=none --enable-fast=yes --with-device=ch4:ucx   && make -j 8 && make install 
cd ..

# Intel MPI 2018 (update 4)
IMPI_VERSION="2018.4.274"
CFG="IntelMPI-v2018.x-silent.cfg"
wget http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13651/l_mpi_${IMPI_VERSION}.tgz
wget https://raw.githubusercontent.com/jithinjosepkl/azhpc-images/master/config/${CFG}
tar -xvf l_mpi_${IMPI_VERSION}.tgz
cd l_mpi_${IMPI_VERSION}
./install.sh --silent /tmp/mpi/${CFG}
cd ..

#cd && rm -rf /tmp/mpi
cd 

# Setup module files for MPIs
mkdir -p /usr/share/Modules/modulefiles/mpi/

# HPC-X
cat << EOF >> /usr/share/Modules/modulefiles/mpi/hpcx-${HPCX_VERSION}
#%Module 1.0
#
#  HPCx 2.4.1
#
conflict        mpi
prepend-path    PATH            /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi/bin
prepend-path    PATH            /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64
prepend-path    LD_LIBRARY_PATH /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi/lib
prepend-path    MANPATH         /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi/share/man
setenv          MPI_BIN         /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi/bin
setenv          MPI_INCLUDE     /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi/include
setenv          MPI_LIB         /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi/lib
setenv          MPI_MAN         /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi/share/man
setenv          MPI_HOME        /opt/hpcx-${HPCX_VERSION}-gcc-MLNX_OFED_LINUX-4.6-1.0.1.1-redhat7.6-x86_64/ompi
EOF

# MPICH
cat << EOF >> /usr/share/Modules/modulefiles/mpi/mpich-${MPICH_VERSION}
#%Module 1.0
#
#  MPICH ${MPICH_VERSION}
#
conflict        mpi
prepend-path    PATH            /opt/mpich-${MPICH_VERSION}/bin
prepend-path    LD_LIBRARY_PATH /opt/mpich-${MPICH_VERSION}/lib
prepend-path    MANPATH         /opt/mpich-${MPICH_VERSION}/share/man
setenv          MPI_BIN         /opt/mpich-${MPICH_VERSION}/bin
setenv          MPI_INCLUDE     /opt/mpich-${MPICH_VERSION}/include
setenv          MPI_LIB         /opt/mpich-${MPICH_VERSION}/lib
setenv          MPI_MAN         /opt/mpich-${MPICH_VERSION}/share/man
setenv          MPI_HOME        /opt/mpich-${MPICH_VERSION}
EOF

# MVAPICH2
cat << EOF >> /usr/share/Modules/modulefiles/mpi/mvapich2-${MV2_VERSION}
#%Module 1.0
#
#  MVAPICH2 2.3
#
conflict        mpi
prepend-path    PATH            /opt/mvapich2-${MV2_VERSION}/bin
prepend-path    LD_LIBRARY_PATH /opt/mvapich2-${MV2_VERSION}/lib
prepend-path    MANPATH         /opt/mvapich2-${MV2_VERSION}/share/man
setenv          MPI_BIN         /opt/mvapich2-${MV2_VERSION}/bin
setenv          MPI_INCLUDE     /opt/mvapich2-${MV2_VERSION}/include
setenv          MPI_LIB         /opt/mvapich2-${MV2_VERSION}/lib
setenv          MPI_MAN         /opt/mvapich2-${MV2_VERSION}/share/man
setenv          MPI_HOME        /opt/mvapich2-${MV2_VERSION}
EOF

# OpenMPI
cat << EOF >> /usr/share/Modules/modulefiles/mpi/openmpi-${OMPI_VERSION}
#%Module 1.0
#
#  OpenMPI ${OMPI_VERSION}
#
conflict        mpi
prepend-path    PATH            /opt/openmpi-${OMPI_VERSION}/bin
prepend-path    LD_LIBRARY_PATH /opt/openmpi-${OMPI_VERSION}/lib
prepend-path    MANPATH         /opt/openmpi-${OMPI_VERSION}/share/man
setenv          MPI_BIN         /opt/openmpi-${OMPI_VERSION}/bin
setenv          MPI_INCLUDE     /opt/openmpi-${OMPI_VERSION}/include
setenv          MPI_LIB         /opt/openmpi-${OMPI_VERSION}/lib
setenv          MPI_MAN         /opt/openmpi-${OMPI_VERSION}/share/man
setenv          MPI_HOME        /opt/openmpi-${OMPI_VERSION}
EOF

#IntelMPI-v2018
cat << EOF >> /usr/share/Modules/modulefiles/mpi/impi_${IMPI_VERSION}
#%Module 1.0
#
#  Intel MPI ${IMPI_VERSION}
#
conflict        mpi
prepend-path    PATH            /opt/intel/impi/${IMPI_VERSION}/intel64/bin
prepend-path    LD_LIBRARY_PATH /opt/intel/impi/${IMPI_VERSION}/intel64/lib
prepend-path    MANPATH         /opt/intel/impi/${IMPI_VERSION}/man
setenv          MPI_BIN         /opt/intel/impi/${IMPI_VERSION}/intel64/bin
setenv          MPI_INCLUDE     /opt/intel/impi/${IMPI_VERSION}/intel64/include
setenv          MPI_LIB         /opt/intel/impi/${IMPI_VERSION}/intel64/lib
setenv          MPI_MAN         /opt/intel/impi/${IMPI_VERSION}/man
setenv          MPI_HOME        /opt/intel/impi/${IMPI_VERSION}/intel64
EOF

cd && rm -rf /tmp/mpi
