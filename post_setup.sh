#!/bin/bash

source /local/onvm/openNetVM/scripts/setup_cloudlab.sh

echo "setting DPDK/ONVM"
yes n | /local/onvm/openNetVM/scripts/setup_environment.sh

echo "Setting up geniuser account"
cat mware.pub >> ~geniuser/.ssh/authorized_keys
sudo usermod -s /bin/bash geniuser
echo "source /local/onvm/openNetVM/scripts/setup_cloudlab.sh" >> ~geniuser/.bashrc


# Script to add a user to Linux system
echo "Setting up tutorial account"

if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -s -p "Enter password : " password
	username="tutorial"
	pass="paUoMiT7vjLqo"    # this is the encrypted password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
	else
		# pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass $username
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system"
fi

mkdir ~tutorial/.ssh
chown tutorial ~tutorial/.ssh
cat mware.pub >> ~tutorial/.ssh/authorized_keys
chown tutorial ~tutorial/.ssh/*
sudo usermod -s /bin/bash tutorial
echo "source /local/onvm/openNetVM/scripts/setup_cloudlab.sh" >> ~tutorial/.bashrc

