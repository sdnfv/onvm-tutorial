#!/bin/bash

touch /tmp/starting

cd /local/onvm/onvm-tutorial
sudo git pull

# All actual setup commands are in post_setup
sudo bash ./post_setup.sh | tee /tmp/setup.log

touch /tmp/done
echo "Done."
