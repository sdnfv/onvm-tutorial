
# ONVM Tutorial at SIGCOMM 2018

Here is the server information we will be using:

**Group A:**
```
ssh tutorial@node1.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us  # (instructor node) 	
ssh tutorial@node2.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node3.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node4.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node5.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node6.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node7.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node8.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node9.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node10.hpnfv1.gwcloudlab-pg0.wisc.cloudlab.us # (instructor node) 
```

**Group B:**
```
ssh tutorial@node1.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us  # (instructor node) 	
ssh tutorial@node2.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node3.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node4.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node5.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node6.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node7.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node8.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node9.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us
ssh tutorial@node10.hpnfv2.gwcloudlab-pg0.wisc.cloudlab.us # (instructor node) 
```

**Group C: (Instructor test nodes)**
```
node1	ssh tutorial@c220g2-011332.wisc.cloudlab.us
node2	ssh tutorial@c220g2-011329.wisc.cloudlab.us
node3	ssh tutorial@c220g2-011327.wisc.cloudlab.us
```


You will be assigned a specific node.  Please do not use any servers not assigned to you. You may only use these servers for the tutorial; let me know if you want to keep playing with things after the session ends.

Thanks to [CloudLab.us](http://cloudlab.us) for the servers! These servers are of type c220g1 or c220g2 from the Wisconsin site, with 8-10 CPU cores, 160GB RAM, and a Dual-port Intel X520 10Gb NIC.

## 1. Log in and Setup Environment

Log into your server using the username and password provided in the slides. Open **TWO** SSH connections to your server (one for the manager, one for running an NF).

After you log in, run these commands **in one terminal** and verify you are now in the `/local/openNetVM/` directory.  **Be sure to run each command line that doesn't start with a `#` comment!**
```bash
############# STEP 1 COMMANDS #############

# become root
sudo -s
# change to ONVM main directory and look around
cd $ONVM_HOME
ls -l
pwd
# configure DPDK to use NICs instead of kernel stack
./scripts/setup_nics.sh dpdk
```

Repeat the commands **in the second terminal**, except for the last line.

**Don't proceed to the next step until instructed.**

## 2. DPDK Basic Forwarding
We will start with the simplest DPDK example that forwards packets from one interface to another.

```bash
############# STEP 2 COMMANDS #############
# Chanage to the DPDK forwarding example
cd $RTE_SDK/examples/skeleton
./go.sh   ## this is equivalent to: ./build/basicfwd -l 1 -n 4

```
This will display some output as DPDK initializes the ports for forwarding.

Now the instructor will send traffic through the host... if all the forwarders have been started correctly we will see it come out the other side!

To understand how this works, look at the `basicfwd.c` file, which is well documented here: http://doc.dpdk.org/guides/sample_app_ug/skeleton.html

**Next we will learn about OpenNetVM. Don't proceed to the next step until instructed.**

## 3. Start the ONVM NF Manager

Use these commands to start the NF Manager. It will display some logs from DPDK, and then start a stats loop that displays information about network ports and active NFs.

```bash
############# STEP 3 COMMANDS #############

cd $ONVM_HOME/onvm
./go.sh  0,1,2  3 -s stdout
# usage: ./go.sh CORE_LIST PORT_BITMASK
```
The above command starts the manager using cores 0, 1, and 2. It uses a bitmaks of 3 to specify that ports 1 and 2 should be used (3 = 0b11).

You should see output like the following:
```
Port 0: '90:e2:ba:b5:01:f4'     Port 1: '90:e2:ba:b5:01:f5'

Port 0 - rx:        0  (        0 pps) tx:         0  (        0 pps)
Port 1 - rx:        0  (        0 pps) tx:         0  (        0 pps)

NFS
```
This shows no packets have arrived and there are currently no NFs.

**Don't proceed to the next step until instructed.**

## 4. Speed Tester Benchmark
Next use your second window to start the Speed Tester NF.  When run in this way, the Speed Tester simply creates a batch of packets and repeatedly sends them to itself in order to stress test the management system.

**Be sure the manager is still running in your other window.**

```bash
############# STEP 4 COMMANDS #############
cd $ONVM_HOME/examples/speed_tester
./go.sh 3 1 1
# usage: ./go.sh CORE_LIST NF_ID DEST_ID
```

You should see output like this:
```
Total packets: 170000000
TX pkts per second:  21526355
Packets per group: 128
```
This shows the NF is able to process about 21 million packets per second. You can see the code for the [Speed Tester NF here](https://github.com/sdnfv/openNetVM/blob/develop/examples/simple_forward/forward.c#L152).

**Kill the speed tester by pressing `ctrl-c` before proceeding to the next step.**  Leave the manager running.


## 5. Bridging Ports
After killing the speed tester, use the same window to run the Bridge NF.  This NF reads packets from one port and sends them out the other port. You can see the code for the [Bridge NF here](https://github.com/sdnfv/openNetVM/blob/develop/examples/bridge/bridge.c#L141), it is quite a bit simpler than the [equivalent DPDK example](https://github.com/sdnfv/onvm-dpdk/blob/onvm/examples/skeleton/basicfwd.c) since the OpenNetVM manager handles the low-level details.

```bash
############# STEP 5 COMMANDS #############

cd ../bridge
./go.sh 3 1
# usage: ./go.sh CORE_LIST NF_ID
```
We are running the NF using core 3 (since the manager used 0-2) and assigning it service ID 1 since by default the manager delivers all new packets to that service. 

**Keep your bridge NF running until we have the full chain of servers working.**

## 6. Chaining Within a Server
OpenNetVM is primarily designed to facilitate service chaining within a server. NFs can specify whether packets should be sent out the NIC or delivered to another NF based on a service ID number. Next we will run a chain of two NFs on each server. The first NF will be a "Simple Forward" NF that sends all incoming packets to a different NF. The second will be the Bridge NF used above that transmits the packets out the NIC.

**You will need to open another terminal on your server so that you can simultaneously run the manager, the Bridge, and the Simple Forward NFs.** Use these commands in each terminal:

```bash
############# STEP 6 COMMANDS #############

# Terminal 1: ONVM Manager (skip this if it is already running)
cd $ONVM_HOME/onvm
./go.sh  0,1,2  3 -s stdout
# parameters: CPU cores=0, 1, and 2, Port bitmask=3 (first two ports), and send stats to stdout

# Terminal 2: Simple Forward NF
cd $ONVM_HOME/examples/simple_forward
./go.sh  3 1 2
# parameters: CPU core=3, ID=1, Destination ID=2

# Terminal 3: Bridge NF
cd $ONVM_HOME/examples/bridge
./go.sh  4 2
# parameters: CPU core=4, ID=2

```
Be sure that your Simple Forward NF has ID 1 (so the manager will use it as the default NF) and that its destination ID is the same ID as your Bridge NF. Also be sure that the NFs are assigned different CPU cores. If you want, you can run multiple Simple Forward NFs in a chain, but be sure the final NF is a Bridge. You will be limited by the number of available CPU cores.

**Keep your chain of NFs running until we have the full chain of chains working.**


## Help!? Troubleshooting Guide
Check the following:
  - Are you running the NF manager?  It should print stats every few seconds if it is working correctly. It must be started before any other NFs.
  - Did you bind the NIC ports to DPDK using the `$ONVM_HOME/scripts/setup_nics.sh dpdk` command? If you don't do this you will get a `WARNING: requested port 0 not present - ignoring` error when running the manager.
  - Does the manager fail to start with an error about huge pages? Be sure you don't have an old version of the manager running: `killall onvm_mgr` Try running `rm -rf /mnt/huge/rte*` to clean out the old huge pages.
  - Is performance terrible?  Make sure you aren't using the same core for two NFs or for both the manager and an NF.  The core IDs in the lists should be unique and all from the same socket.  Run `$ONVM_HOME/scripts/corehelper.py -c` to see a list of core IDs and their mapping to sockets.

## Instructor Notes
To send traffic through the chain run these commands on the FIRST and LAST nodes in the chain:
```bash
# be sure you are running as root
sudo -s

# be sure NICs are properly configured to use kernel interface
$ONVM_HOME/scripts/setup_nics.sh kernel

# set IP on the FIRST node:
ifconfig eth2 192.168.1.1

# set the IP on the LAST node:
ifconfig eth2 192.168.1.12

```

Now you can send traffic with these commands:
```bash
# run on first node to send to last
ping 192.168.1.12

# run on LAST node to act as iperf server
iperf -s

# run on FIRST node to send to iperf server on last
iperf -i 5 -t 60 -c 192.168.1.12
```

Other setup notes:
```
# Set password
sudo passwd tutorial

# copy NIC setup script
cp /local/onvm/onvm-tutorial/setup_nics.sh /local/onvm/openNetVM/scripts/

# enable password-based SSH access on each server: 
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config; sudo service ssh restart

```
