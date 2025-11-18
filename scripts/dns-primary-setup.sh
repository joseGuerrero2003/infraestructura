#!/bin/bash
mkdir -p /etc/bind/master_zones /etc/bind/journals /etc/bind/keys
cp dns-primary/master_zones/* /etc/bind/master_zones/
cp dns-primary/keys/* /etc/bind/keys/
systemctl restart bind9
