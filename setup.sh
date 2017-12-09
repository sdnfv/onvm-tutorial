#!/bin/bash

cd /local/onvm/onvm-tutorial
git pull

cat mware.pub >> ~geniuser/.ssh/authorized_keys

./post_setup.sh