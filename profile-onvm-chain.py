"""A chain of servers running OpenNetVM. Each server has tools such as iperf and nginx.

Instructions:
Specify the chain length (minimum of 3). To initialize OpenNetVM run:
```
  cd /local/onvm/openNetVM/scripts  
  source setup_cloudlab.sh  
  ./setup_environment.sh
```

"""

import geni.portal as portal
import geni.rspec.pg as rspec

# Create a Request object to start building the RSpec.
request = portal.context.makeRequestRSpec()

# Describe the parameter(s) this profile script can accept.
portal.context.defineParameter( "n", "Number of Hosts (minimum 3)", portal.ParameterType.INTEGER, 3 )

# Retrieve the values the user specifies during instantiation.
params = portal.context.bindParameters()

nodes = []
cnt = 1
NUM_NODES = params.n
# NODE_TYPE = "c220g2"

for n in range(NUM_NODES):
	node = request.RawPC("node" + str(cnt))
	# node.hardware_type = NODE_TYPE
	node.disk_image = 'urn:publicid:IDN+wisc.cloudlab.us+image+gwcloudlab-PG0:ONVM-tut:1'
	node.addService(rspec.Execute(shell="bash", command="/local/onvm/onvm-tutorial/setup.sh"))
	nodes.append(node)	
	cnt = cnt + 1

# Link 1---(n-2)
for n in range(1,NUM_NODES-2):
	if1 = nodes[n].addInterface()
	if2 = nodes[n+1].addInterface()
	link = request.Link("link" + str(n) + "-" + str(n+1))
	link.addInterface(if1)
	link.addInterface(if2)

# Link 0---1
n = 0
if1 = nodes[n].addInterface()
if1.addAddress(rspec.IPv4Address("192.168.1.1", "255.255.255.0"))
if2 = nodes[n+1].addInterface()
link = request.Link("link" + str(n) + "-" + str(n+1))
link.addInterface(if1)
link.addInterface(if2)
# Link (n-2)---(n-1)
n = NUM_NODES-2
if1 = nodes[n].addInterface()
if2 = nodes[n+1].addInterface()
if2.addAddress(rspec.IPv4Address("192.168.1." + str(NUM_NODES), "255.255.255.0"))
link = request.Link("link" + str(n) + "-" + str(n+1))
link.addInterface(if1)
link.addInterface(if2)

# Print the RSpec to the enclosing page.
portal.context.printRequestRSpec()
