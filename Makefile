# Ansible makefile for setting up a proxmox host
SHELL=/bin/bash

# You may need to change this if you're not xrobau
OVF=VMware-ovftool-4.4.2-17901668-lin.x86_64.bundle
OVFURL=https://www.dropbox.com/s/jcj1jeody1m56pi/$(OVF)

# Allow xrobau, he's a nice guy. "Honest" Rob.
SSHKEYS=xrobau

# Base prep here
TMPDIR=$(HOME)/.proxmox-ansible
GROUPVARS=$(shell pwd)/group_vars

ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOST_KEY_CHECKING

# Anything here can be automatically made by the $(MKDIRS) target below
MKDIRS=$(TMPDIR) $(GROUPVARS) $(GROUPVARS)/all

# Things that are always needed
TOOLS += curl vim ping wget netstat
PKG_ping=iputils-ping
PKG_netstat=net-tools

# This is first so we always have a default that is harmless (assuming
# you think that 'make setup' is harmless, which I think it is!)
.PHONY: halp
halp: setup
	@echo "You probably want to run 'make proxmox' now."
	@echo "If you are using this to upgrade from 7 to 8, run 'make upgrade'"

# Drag in any includes
include $(wildcard includes/Makefile.*)

# This is anything that's in TOOLS or STOOLS
PKGS=$(addprefix /usr/bin/,$(TOOLS))
SPKGS=$(addprefix /usr/sbin/,$(STOOLS))
STARGETS += $(PKGS) $(SPKGS)

NOIPMI=$(shell [ -e /etc/noipmi ] && echo '-e noipmi=true')
PVE7TO8=$(shell [ -e /usr/bin/pve7to8 ] && echo '-e pve7to8=true')
ANSIBLE=$(ANSBIN) $(NOIPMI) $(PVE7TO8)

.PHONY: setup
setup: $(STARGETS)

# Just make anything in MKDIRS, easy DRY.
$(MKDIRS):
	mkdir -p $@

# This installs whatever is needed in /usr/bin or /usr/sbin
/usr/bin/% /usr/sbin/%:
	@p="$(PKG_$*)"; p=$${p:=$*}; apt-get -y install $$p || ( echo "Don't know how to install $*, add PKG_$*=dpkgname to the makefile"; exit 1 )
