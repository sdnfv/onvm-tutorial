#!/bin/bash

chmod -R g+w /local/onvm/*

source /local/onvm/openNetVM/scripts/setup_cloudlab.sh

echo "setting DPDK/ONVM"
yes n | /local/onvm/openNetVM/scripts/setup_environment.sh

echo "Setting up geniuser account"
cat mware.pub >> ~geniuser/.ssh/authorized_keys
sudo usermod -s /bin/bash geniuser
echo "source /local/onvm/openNetVM/scripts/setup_cloudlab.sh" >> ~geniuser/.bashrc


echo "Setting up tutorial account"
if [ $(id -u) -eq 0 ]; then
	username="tutorial"
	pass="paUoMiT7vjLqo"    # this is the encrypted password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
	else
		# pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass -G root $username
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system"
fi

mkdir ~tutorial/.ssh
cat mware.pub >> ~tutorial/.ssh/authorized_keys
chmod 600 ~tutorial/.ssh/authorized_keys
chown -R tutorial ~tutorial
sudo usermod -s /bin/bash tutorial
grep "setup_cloudlab.sh" ~tutorial/.bashrc >/dev/null
if [ $? -eq 0 ]; then
	echo "tutorial bashrc already has setup_cloudlab scripts"
else
	echo "source /local/onvm/openNetVM/scripts/setup_cloudlab.sh; unset ONVM_PATH" >> ~tutorial/.bashrc
fi

echo "Setup ONVM environment for all users"
for f in /users/*/.bashrc
do
	grep "setup_cloudlab.sh" $f >/dev/null
	if [ $? -eq 0 ]; then
		echo "$f already has ONVM setup"
	else
		echo "source /local/onvm/openNetVM/scripts/setup_cloudlab.sh; unset ONVM_PATH" >> $f
	fi
done

