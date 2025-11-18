#!/bin/bash
apt install freeradius -y
cp freeradius/clients.conf /etc/freeradius/3.0/clients.conf
cp freeradius/users /etc/freeradius/3.0/users
systemctl enable freeradius
systemctl restart freeradius
