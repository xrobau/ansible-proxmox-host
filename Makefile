# Ansible makefile for setting up a proxmox host

SHELL=/bin/bash

halp: setup
	@echo Read the Makefile

ANSBIN=/usr/bin/ansible-playbook
ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOST_KEY_CHECKING

.PHONY: setup
setup: $(ANSBIN) ansible-collections base-packages /etc/network/example.interfaces

.PHONY: proxmox
proxmox: | setup
	$(ANSBIN) -i localhost, proxmox.yml

.PHONY: kexec
kexec: | setup
	$(ANSBIN) -i localhost, kexec.yml

.PHONY: update
update:
	apt-get update
	apt-get -y --purge autoremove
	apt-get -y dist-upgrade
	apt-get remove --purge $$(dpkg -l | awk '/^r/ {print $$2}')

/etc/network/example.interfaces: example.interfaces
	@cp $< $@
	@echo "NOTE: /etc/network/example.interfaces has been created."
	@echo "Please use that as a template to create the OVS interfaces config"
	@echo "after the grub configuration has been updated."
	@echo "You will only see this once. Please re-run the make command"
	@exit 1

$(ANSBIN): | base-packages
	apt-get -y install ansible

.PHONY: ansible-collections
ansible-collections: ~/.ansible/collections/ansible_collections/community/general ~/.ansible/roles/jhu-sheridan-libraries.postfix-smarthost/README.md ~/.ansible/roles/geerlingguy.php/README.md ~/.ansible/roles/geerlingguy.php-versions ~/.ansible/collections/ansible_collections/ansible/posix/MANIFEST.json

~/.ansible/collections/ansible_collections/ansible/posix/MANIFEST.json:
	ansible-galaxy collection install ansible.posix

~/.ansible/roles/jhu-sheridan-libraries.postfix-smarthost/README.md:
	ansible-galaxy install jhu-sheridan-libraries.postfix-smarthost

~/.ansible/roles/geerlingguy.php/README.md:
	ansible-galaxy install geerlingguy.php

~/.ansible/roles/geerlingguy.php-versions:
	ansible-galaxy install geerlingguy.php-versions

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



