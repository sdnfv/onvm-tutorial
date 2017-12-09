#!/bin/bash

cd /local/onvm/onvm-tutorial
git pull

# All actual setup commands are in post_setup
./post_setup.sh | tee /tmp/setup.log

echo "Done."
