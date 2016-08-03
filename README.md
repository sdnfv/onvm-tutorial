
# ONVM Tutorial at CleanSky ITN 8/3/16

Here is the server information we will be using:
```
node 1       ssh tutorial@c220g2-011003.wisc.cloudlab.us
node 2       ssh tutorial@c220g2-011007.wisc.cloudlab.us
node 3       ssh tutorial@c220g2-011306.wisc.cloudlab.us
node 4       ssh tutorial@c220g2-011313.wisc.cloudlab.us
node 5       ssh tutorial@c220g2-011308.wisc.cloudlab.us
node 6       ssh tutorial@c220g2-011317.wisc.cloudlab.us
node 7       ssh tutorial@c220g2-011307.wisc.cloudlab.us
node 8       ssh tutorial@c220g2-011315.wisc.cloudlab.us
```
You will be assigned node 3, 4, 5, 6, or 7.  Please do not use any servers not assigned to you. You may only use these servers for the tutorial; let me know if you want to keep playing with things after the session ends.

Thanks to [CloudLab.us](http://cloudlab.us) for the servers! These servers are of type c220g2 from the Wisconsin site, with Two Intel E5-2660 v3 10-core CPUs at 2.60 GHz (Haswell EP), 160GB RAM, and a Dual-port Intel X520 10Gb NIC.

## Log in and Setup Environment

Log into your server using the username and password provided in the slides. Open two SSH connections to your server (one for the manager, one for running an NF).

After you log in, run these commands **in both terminals** and verify you are now in the `/local/openNetVM/` directory.
```bash
# become root
sudo -s
# load environment variables
source /local/config_onvm.sh
# change to ONVM main directory
cd $ONVM
ls -l
pwd
```

**Don't proceed to the next step until instructed.**

## Start the ONVM NF Manager

Use these commands to start the NF Manager. It will display some logs from DPDK, and then start a stats loop that displays information about network ports and active NFs.

```bash
cd $ONVM/onvm
./go.sh  0,1,2,3  3
# usage: ./go.sh CORE_LIST PORT_LIST
```
The above command starts the manager using cores 0, 1, 2, and 3. It uses a bitmaks of 3 to specify that ports 1 and 2 should be used (3 = 0b11).

You should see output like the following:
```
Port 0: '90:e2:ba:b5:01:f4'     Port 1: '90:e2:ba:b5:01:f5'

Port 0 - rx:        0  (        0 pps) tx:         0  (        0 pps)
Port 1 - rx:        0  (        0 pps) tx:         0  (        0 pps)

CLIENTS
```
This shows no packets have arrived and there are currently no clients (NFs).

**Don't proceed to the next step until instructed.**

## Speed Tester Benchmark
Next use your second window to start the Speed Tester NF.  When run in this way, the Speed Tester simply creates a batch of packets and repeatedly sends them to itself in order to stress test the management system.

**Be sure the manager is still running in your other window.**

```bash
cd $ONVM/examples/speed_tester
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

## Bridging Ports
After killing the speed tester, use the same window to run the Bridge NF.  This NF reads packets from one port and sends them out the other port.

```bash
cd examples/bridge
./go.sh 4 1
# usage: ./go.sh CORE_LIST NF_ID
```
We are running the NF using core 4 (since the manager used 0-3) and assigning it service ID 1 since by default the manager delivers all new packets to that service.

**Keep your bridge NF running until we have the full chain of 8 servers working.  (Cross your fingers this will work)**

