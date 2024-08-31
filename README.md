# Proxmox host configurator

Note this is run in TWO STAGES.

# Recent Changes

* 2024-08-31: Update to work with latest proxmox
* 2023-02-02: Switch to 6.1 pve kernel
* 2023-02-02: Increase system default filehandles

## Stage 0 (Host preparation)

You will most likely need to run `apt-get -y install git make` to
check out this repo.

Make sure you can access the console of this machine to fix any
mistakes you might make with the network configuration. If this
is a server, you should be able to use `ipmitool lan print` to
see the IP address of the remote console, and use that.

Unless you are planning on doing GPU passthrough, make sure things
like 'VT-d' and 'SR-IOV' are disabled in the BIOS of the host.

### VM/Container Networking
Decide how you are going to do your networking between hosts, vms,
containers, and the internet. Usually a simple bridged connection
is sufficient, which is in the example configuration installed
below.

Network cards should _almost never_ be passed through to a client,
unless that client is a dedicated router that is running DPDK or
XDP itself, and you are expecting that VM to route more than 1m
packets per second (Normally for that usage it would be on dedicated
hardware anyway, for reliability).

## Stage 0 - Interface Example file
The first time `make proxmox` is run, it will place some example
interface files in /etc/network/interfaces and then exit. You can
use those to prepare the host for the standard proxmox network
configuration.

You should copy `/etc/network/example.interfaces` into place,
and configure it to match your network layout.

### Don't use OVS unless you know why you want to!
There is almost no reason to use OVS for host connectivity, and is
actively discouraged if you are planning on using LACP (802.3ad).
It is purely provided because some people want to try it!

There is an example /etc/network/example.interfaces.ovs file created,
which you can use as a template to replace your current interfaces
file.

### Double check console access!
After you have done that, **CHECK YOU CAN GET IN VIA OUT OF BAND ACCESS**
Obviously, if you're right in front of the machine, you can use the physical
keyboard and monitor!

## Stage 1 - Bootstrap
You can now run `make proxmox` again, and it will prepare the machine for
use. It will error if `eth0` does not exist (which it should not), and you
should now reboot (after configuring `/etc/network/interfaces`) the host.

## Stage 2 - Reboot
If you correctly updated the interfaces file, everything should just
work. Otherwise edit it again via the console and run `ifdown -a` and
then `ifup -a` to reapply the network changes.

## Stage 3 - Final Configuration
The second time you run `make proxmox` the rest of the machine will be
configured, enabling kexec and other tweaks.

There may be a slight race condition when enabling kexec - you can run
`make proxmox` a second time to make sure kexec is loaded and ready, and
then reboot the machine to make sure it does a kexec reboot, instead a
full reboot.


