#!/bin/bash

set -x

# Install Mellanox OFED
mkdir -p /tmp/mlnxofed
cd /tmp/mlnxofed
wget http://www.mellanox.com/downloads/ofed/MLNX_OFED-4.6-1.0.1.1/MLNX_OFED_LINUX-4.6-1.0.1.1-rhel7.6-x86_64.tgz
tar zxvf MLNX_OFED_LINUX-4.6-1.0.1.1-rhel7.6-x86_64.tgz

KERNEL=$(uname -r)
./MLNX_OFED_LINUX-4.6-1.0.1.1-rhel7.6-x86_64/mlnxofedinstall --kernel-sources /usr/src/kernels/$KERNEL --add-kernel-support --skip-repo
cd && rm -rf /tmp/mlnxofed

/etc/init.d/openibd restart
cd && rm -rf /tmp/mlnxofed

# Configure WALinuxAgent
sed -i -e 's/# OS.EnableRDMA=y/OS.EnableRDMA=y/g' /etc/waagent.conf
sed -i -e 's/CGroups.EnforceLimits=n/CGroups.EnforceLimits=y/g' /etc/waagent.conf
systemctl restart waagent
