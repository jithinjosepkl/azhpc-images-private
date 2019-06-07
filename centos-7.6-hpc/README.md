# Prepare HPC-ready VM

The script installs/sets up the following:

- Update memory limits
- Enable `zone_reclaim` mode
- Install Development tools and pre-reqs for MPI installations
- Install Mellanox OFED (MLNX_OFED-4.6-1.0.1.1)
- Install WALinuxAgent (2.2.38)
- Setp IPoIB
- Install gcc v8.2
- Install MPI Libraries as modules
  - HPC-X v2.4.1
  - MPICH 3.3
  - MVAPICH2 2.3.1
  - OpenMPI 4.0.1
 
 # Run scripts:
 Run `./setup_node.sh`
