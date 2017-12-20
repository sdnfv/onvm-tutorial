
# ONVM Tutorial at Middleware 12/11/17

Here is the server information we will be using:
```
node1   ssh tutorial@c220g2-011301.wisc.cloudlab.us     
node2   ssh tutorial@c220g2-011313.wisc.cloudlab.us     
node3   ssh tutorial@c220g2-011316.wisc.cloudlab.us     
node4   ssh tutorial@c220g2-011314.wisc.cloudlab.us     
node5   ssh tutorial@c220g2-011317.wisc.cloudlab.us     
node6   ssh tutorial@c220g2-011130.wisc.cloudlab.us     
node7   ssh tutorial@c220g2-011132.wisc.cloudlab.us     
node8   ssh tutorial@c220g2-011131.wisc.cloudlab.us     
node9   ssh tutorial@c220g2-011126.wisc.cloudlab.us     
node10  ssh tutorial@c220g2-011124.wisc.cloudlab.us     
node11  ssh tutorial@c220g2-011117.wisc.cloudlab.us     
node12  ssh tutorial@c220g2-011123.wisc.cloudlab.us    
```

You will be assigned a specific node.  Please do not use any servers not assigned to you. You may only use these servers for the tutorial; let me know if you want to keep playing with things after the session ends.

Thanks to [CloudLab.us](http://cloudlab.us) for the servers! These servers are of type c220g1 or c220g2 from the Wisconsin site, with 8-10 CPU cores, 160GB RAM, and a Dual-port Intel X520 10Gb NIC.

## 1. Log in and Setup Environment

Log into your server using the username and password provided in the slides. Open two SSH connections to your server (one for the manager, one for running an NF).

After you log in, run these commands **in one terminal** and verify you are now in the `/local/openNetVM/` directory.
```bash
# become root
sudo -s
# change to ONVM main directory
cd $ONVM_HOME
ls -l
pwd
# configure DPDK to use NICs
./scripts/setup_nics.sh dpdk
```

Repeat the commands **in the second terminal**, except for the last line.

**Don't proceed to the next step until instructed.**

## 2. Start the ONVM NF Manager

Use these commands to start the NF Manager. It will display some logs from DPDK, and then start a stats loop that displays information about network ports and active NFs.

```bash
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

CLIENTS
```
This shows no packets have arrived and there are currently no clients (NFs).

**Don't proceed to the next step until instructed.**

## 3. Speed Tester Benchmark
Next use your second window to start the Speed Tester NF.  When run in this way, the Speed Tester simply creates a batch of packets and repeatedly sends them to itself in order to stress test the management system.

**Be sure the manager is still running in your other window.**

```bash
cd $ONVM_HOME/examples/speed_tester
./go.sh 4 1 1
# usage: ./go.sh CORE_LIST NF_ID DEST_ID
```

You should see output like this:
```
Total packets: 170000000
TX pkts per second:  21526355
Packets per group: 128
```
This shows the NF is able to process about 21 million packets per second.

**Kill the speed tester by pressing `ctrl-c` before proceeding to the next step.**  Leave the manager running.

## 4. Bridging Ports
After killing the speed tester, use the same window to run the Bridge NF.  This NF reads packets from one port and sends them out the other port.

```bash
cd ../bridge
./go.sh 4 1
# usage: ./go.sh CORE_LIST NF_ID
```
We are running the NF using core 4 (since the manager used 0-2) and assigning it service ID 1 since by default the manager delivers all new packets to that service.

**Keep your bridge NF running until we have the full chain of 8 servers working.  (Cross your fingers this will work)**

## Help!? Troubleshooting Guide
Check the following:
  - Are you running the NF manager?  It should print stats every few seconds if it is working correctly. It must be started before any other NFs.
  - Did you bind the NIC ports to DPDK using the `$ONVM_HOME/scripts/setup_nics.sh dpdk` command?
  - Does the manager fail to start with an error about huge pages? Be sure you don't have an old version of the manager running: `killall onvm_mgr` Try running `rm -rf /mnt/huge/rte*` to clean out the old huge pages.
  - Is performance terrible?  Make sure you aren't using the same core for two NFs or for both the manager and an NF.  The core IDs in the lists should be unique and all from the same socket.  Run `$ONVM_HOME/scripts/corehelper.py -c` to see a list of core IDs and their mapping to sockets.

## Instructor Notes
To send traffic through the chain run these commands on the FIRST and LAST nodes in the chain:
```
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
```
# run on first node to send to last
ping 192.168.1.12

# run on LAST node to act as iperf server
iperf -s

# run on FIRST node to send to iperf server on last
iperf -i 5 -t 60 -c 192.168.1.12
```
