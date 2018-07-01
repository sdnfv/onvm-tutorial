#!/bin/bash

#                        openNetVM
#                https://sdnfv.github.io
#
# OpenNetVM is distributed under the following BSD LICENSE:
#
# Copyright(c)
#       2015-2017 George Washington University
#       2015-2017 University of California Riverside
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# * The name of the author may not be used to endorse or promote
#   products derived from this software without specific prior
#   written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# A script to bind the dpdk/kernel interfaces
# Loads the specified kernel module to all 10G NIC ports
#     Or to all $ONVM_NIC_PCI NICs if its defined

#DPDK_DEVBIND=$RTE_SDK/usertools/dpdk-devbind.py # for DPDK 17 and up 
DPDK_DEVBIND=$RTE_SDK/tools/dpdk-devbind.py # for DPDK 16.11
#DPK_DEVBIND=#RTE_SDK/tools/dpdk_nic_bind.py # for DPDK 2.2 D

kernel_drv=ixgbe
dpdk_drv=igb_uio

function usage() {
    echo "Usage:"
    echo "./setup_nics.sh dpdk"
    echo "./setup_nics.sh kernel"
}

# Confirm environment variables
if [ -z "$RTE_SDK" ]; then
    echo "Please export \$RTE_SDK"
    exit 1
fi

# Verify sudo access
sudo -v

if pgrep onvm_mgr &> /dev/null
then 
    echo "onvm_mgr needs to be killed to rebind NICs" 
    read -r -p "Kill the manager and continue? [y/N] " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
    then
        sudo killall onvm_mgr
    sleep 2
    else
        echo "Kill the manager to rebind the NIC ports"
        exit 0    
    fi
fi

if [ $# -ne 1 ]; then
    echo "Invalid arg list"
    usage
    exit 1
fi

if [ "$1" == "dpdk" ]; then
    driver=$dpdk_drv
elif [ "$1" == "kernel" ]; then
    driver=$kernel_drv
else
    echo "Invalid driver value"
    usage
    exit 1
fi

# dpdk_nic_bind.py has been changed to dpdk-devbind.py to be compatible with DPDK 16.11
echo "Binding NIC status"
if [ -z "$ONVM_NIC_PCI" ];then
    for id in $($DPDK_DEVBIND --status | grep -v Active | grep -e "10G" -e "10-Gigabit" | cut -f 1 -d " ")
    do
        sudo $DPDK_DEVBIND -b $driver $id
    done
else
    # Auto binding example format: export ONVM_NIC_PCI=" 07:00.0  07:00.1 "
    for nic_id in $ONVM_NIC_PCI
    do
        sudo $DPDK_DEVBIND -b $driver $nic_id
    done
fi

$DPDK_DEVBIND --status

echo "Finished Binding"
