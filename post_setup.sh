#!/bin/bash

source /local/onvm/openNetVM/scripts/setup_cloudlab.sh

echo "setting DPDK/ONVM"
yes n | /local/onvm/openNetVM/scripts/setup_environment.sh

echo "Setting up geniuser account"
cat mware.pub >> ~geniuser/.ssh/authorized_keys
sudo usermod -s /bin/bash geniuser
echo "source /local/onvm/openNetVM/scripts/setup_cloudlab.sh" >> ~geniuser/.bashrc


