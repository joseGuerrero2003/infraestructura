#!/bin/bash
set -e

echo "--- Instalando y configurando DHCP (Kea) ---"

# === Variables ===
KEA_CONF_DIR="/etc/kea"
KEADHCP4_CONF="$KEA_CONF_DIR/kea-dhcp4.conf"
KEADHCP6_CONF="$KEA_CONF_DIR/kea-dhcp6.conf"

DOMAIN="myempresa.test"
DNS1="192.168.50.2"
DNS2="192.168.50.3"

# === Instalación ===
apt-get update -y
apt-get install -y kea-dhcp4-server kea-dhcp6-server

mkdir -p "$KEA_CONF_DIR"

# === Copiar configuraciones (o crearlas) ===
cp ./kea-dhcp4.conf "$KEADHCP4_CONF"
cp ./kea-dhcp6.conf "$KEADHCP6_CONF"

# === Reemplazar variables ===
sed -i "s/{{DNS1}}/$DNS1/g" "$KEADHCP4_CONF"
sed -i "s/{{DNS2}}/$DNS2/g" "$KEADHCP4_CONF"
sed -i "s/{{DOMAIN}}/$DOMAIN/g" "$KEADHCP4_CONF"

# === Habilitar servicios ===
systemctl enable kea-dhcp4-server
systemctl restart kea-dhcp4-server

systemctl enable kea-dhcp6-server
systemctl restart kea-dhcp6-server

echo "--- DHCP configurado correctamente ---"
