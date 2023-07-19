# Ansible makefile for setting up a proxmox host

SHELL=/bin/bash

# You may need to change this if you're not xrobau
OVF=VMware-ovftool-4.4.2-17901668-lin.x86_64.bundle
OVFURL=https://www.dropbox.com/s/jcj1jeody1m56pi/$(OVF)

halp: setup
	@echo Read the Makefile

ANSBIN=/usr/bin/ansible-playbook
ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOST_KEY_CHECKING

NOIPMI=$(shell [ -e /etc/noipmi ] && echo '-e noipmi=true')
PVE7TO8=$(shell [ -e /usr/bin/pve7to8 ] && echo '-e pve7to8=true')
ANSIBLE=$(ANSBIN) $(NOIPMI) $(PVE7TO8)

.PHONY: setup
setup: $(ANSBIN) ansible-collections base-packages /etc/network/example.interfaces.ovs /etc/network/example.interfaces

.PHONY: proxmox
proxmox: | setup
	$(ANSIBLE) -i localhost, proxmox.yml

.PHONY: kexec
kexec: | setup
	$(ANSIBLE) -i localhost, kexec.yml

.PHONY: upgrade
upgrade:
	$(ANSIBLE) -i localhost, upgrade.yml
	@echo "Preparations for the upgrade are complete. At this point, update and upgrade following"
	@echo "the instructions at https://pve.proxmox.com/wiki/Upgrade_from_7_to_8"
	@echo ""
	@echo "When complete, to ensure kexec doesn't get confused, power off and back on this host"

.PHONY: update
update:
	apt-get update
	apt-get -y --purge autoremove
	apt-get -y dist-upgrade
	apt-get remove --purge $$(dpkg -l | awk '/^r/ {print $$2}')

/etc/network/example.interfaces.ovs: example.interfaces.ovs
	@cp $< $@

/etc/network/example.interfaces: example.interfaces.std
	@cp $< $@
	@echo "NOTE: /etc/network/example.interfaces has been created."
	@echo "Please use that as a template to create the proxmox interfaces config"
	@echo "after the grub configuration has been updated."
	@echo "There is also an example.interfaces.ovs that can be used if you wish to"
	@echo "use Open vSwitch, but is not recommended for production use."
	@echo "You will only see this once. Please re-run the make command"
	@echo ""
	@exit 1

$(ANSBIN): | base-packages
	apt-get -y install ansible

.PHONY: ansible-collections
ansible-collections: ~/.ansible/collections/ansible_collections/community/general ~/.ansible/roles/jhu-sheridan-libraries.postfix-smarthost/README.md ~/.ansible/collections/ansible_collections/ansible/posix/MANIFEST.json

~/.ansible/collections/ansible_collections/ansible/posix/MANIFEST.json:
	ansible-galaxy collection install ansible.posix

~/.ansible/roles/jhu-sheridan-libraries.postfix-smarthost/README.md:
	ansible-galaxy install jhu-sheridan-libraries.postfix-smarthost

~/.ansible/collections/ansible_collections/community/general:
	@ansible-galaxy collection install community.general

.PHONY: base-packages
base-packages: /usr/bin/wget /usr/bin/unzip /usr/bin/vim /usr/bin/ping

/usr/bin/wget:
	@apt-get -y install wget

/usr/bin/unzip:
	@apt-get -y install unzip

/usr/bin/vim:
	@apt-get -y install vim

/usr/bin/ping:
	@apt-get -y install iputils-ping

.PHONY: ovftool
ovftool: /usr/bin/ovftool

.PHONY: uninstall-ovftool
uninstall-ovftool: /usr/local/$(OVF)
	@/bin/bash $< --uninstall-product=vmware-ovftool

/usr/bin/ovftool: /usr/local/$(OVF)
	@/bin/bash $< --eulas-agreed

/usr/local/$(OVF): /usr/bin/wget
	@/usr/bin/wget -O $@ $(OVFURL)


