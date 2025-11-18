#!/bin/bash
mkdir -p /etc/bind/slave_zones /var/cache/bind
cp dns-secondary/slave_zones/* /etc/bind/slave_zones/
systemctl restart bind9
