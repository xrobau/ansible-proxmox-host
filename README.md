# Proxmox host configurator

Note this is run in TWO STAGES. The first time `make proxmox` is run,
it will fail after Grub is updated.

## Stage 1

This prepares the machine for Open vSwitch installation, and adds
the needed biosdevname params to Grub.

There is *also* a new /etc/network/interfaces.example file created,
which you should use as a template to replace your current interfaces
file.

After you have done that, **CHECK YOU CAN GET IN VIA OUT OF BAND ACCESS**
and then reboot your machine. If you correctly updated the interfaces
file, everything should just work. Otherwise edit it again via the
Out Of Band Access (that you checked you had access to before you
rebooted) and run `ifdown -a` and then `ifup -a` to reapply the network
changes to use Open vSwitch.

## Stage 2

The second time you run `make proxmox` the rest of the machine will be
configured, enabling kexec and other tweaks.


