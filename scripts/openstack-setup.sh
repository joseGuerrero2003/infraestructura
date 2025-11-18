#!/bin/bash
apt install ansible -y
ansible-playbook -i openstack/inventory openstack/globals.yml
