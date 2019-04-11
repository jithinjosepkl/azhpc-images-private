#!/bin/bash
set -ex

# Update memory limits
./update_config.sh

# Install development tools
./install_dev_tools.sh

# Install OFED, setup IPoIB, and WALinuxAgent
./install_ofed.sh

# Install gcc 8.2
./install_gcc-8.2.sh
cp ./modulefiles/gcc-8.2.0 /usr/share/Modules/modulefiles/

export PATH=/opt/gcc-8.2.0/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-8.2.0/lib64:$LD_LIBRARY_PATH
export CC=/opt/gcc-8.2.0/bin/gcc
export GCC=/opt/gcc-8.2.0/bin/gcc

# Install MPI libraries and Communication Runtimes
./install_mpi.sh

# Setup environment modules for MPI libraries
#mkdir -p /usr/share/Modules/modulefiles/mpi/
#cp ./modulefiles/mpi/* /usr/share/Modules/modulefiles/mpi/

