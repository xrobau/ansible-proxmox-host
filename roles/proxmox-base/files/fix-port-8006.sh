#!/bin/bash

# Remap 8006 to 443 in iptables (so there's no need for anything
# userspace that can break, like a proxy)

# These environment variables are set when bringing the interface up,
# and can be used by post-up scripts
#
# IFACE=vlan206
# IF_ADDRESS=10.60.3.42/24
# IF_GATEWAY=10.60.3.1
# IF_OVS_BRIDGE=vmbr0
# IF_OVS_MTU=1500
# IF_OVS_OPTIONS=tag=206
# IF_OVS_TYPE=OVSIntPort
# IF_POST_UP=/usr/local/bin/fix-port-8006.sh
# LOGICAL=vlan206

# Debugging:
set > /tmp/fix8006.env

# Step 1 - Remove the netmask from IF_ADDRESS
DEST=$(echo $IF_ADDRESS | cut -d/ -f1)

# Step 2 - Remove any older ones hanging around
CURRENT=$(iptables -t nat -L PREROUTING -n --line-numbers | awk '/ports 8006/ { print $1 }' | sort -n -r)
for i in $CURRENT; do
	/usr/sbin/iptables -t nat -D PREROUTING $i
done

# Step 3 - ???
IPT="PREROUTING -p tcp --destination $DEST --dport 443 -j REDIRECT --to-ports 8006"

# Step 4 - Profit!
/usr/sbin/iptables -t nat -A $IPT

