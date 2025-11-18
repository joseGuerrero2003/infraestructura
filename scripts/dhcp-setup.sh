#!/bin/bash
set -euo pipefail

echo "--- Instalando y configurando DHCP (Kea) ---"

# === Variables ===
KEA_CONF_DIR="/etc/kea"
KEADHCP4_CONF="$KEA_CONF_DIR/kea-dhcp4.conf"
KEADHCP6_CONF="$KEA_CONF_DIR/kea-dhcp6.conf"

DOMAIN="myempresa.test"
DNS1="192.168.50.2"
DNS2="192.168.50.3"

# === Instalación de paquetes ===
echo "--- Actualizando paquetes e instalando Kea ---"
apt-get update -y
apt-get install -y kea-dhcp4-server kea-dhcp6-server

# === Crear directorio de configuración si no existe ===
mkdir -p "$KEA_CONF_DIR"

# === Verificar existencia de archivos de configuración ===
if [[ ! -f /vagrant/scripts/kea-dhcp4.conf ]]; then
    echo "ERROR: No se encuentra /vagrant/scripts/kea-dhcp4.conf"
    exit 1
fi
if [[ ! -f /vagrant/scripts/kea-dhcp6.conf ]]; then
    echo "ERROR: No se encuentra /vagrant/scripts/kea-dhcp6.conf"
    exit 1
fi

# === Copiar archivos de configuración ===
cp /vagrant/scripts/kea-dhcp4.conf "$KEADHCP4_CONF"
cp /vagrant/scripts/kea-dhcp6.conf "$KEADHCP6_CONF"

# === Reemplazar variables en DHCPv4 ===
sed -i "s/{{DNS1}}/$DNS1/g" "$KEADHCP4_CONF"
sed -i "s/{{DNS2}}/$DNS2/g" "$KEADHCP4_CONF"
sed -i "s/{{DOMAIN}}/$DOMAIN/g" "$KEADHCP4_CONF"

# === Detectar interfaz de red privada automáticamente ===
PRIVATE_IFACE=$(ip -o link show | awk -F': ' '$2 ~ /^enp0s8$/ {print $2}')
if [[ -z "$PRIVATE_IFACE" ]]; then
    echo "ERROR: No se detectó la interfaz privada enp0s8"
    exit 1
fi
echo "Usando interfaz privada: $PRIVATE_IFACE"

# === Reemplazar interfaz en DHCPv4 conf ===
sed -i "s/{{INTERFACE}}/$PRIVATE_IFACE/g" "$KEADHCP4_CONF"

# === Habilitar y reiniciar servicios ===
echo "--- Habilitando y reiniciando Kea DHCPv4 ---"
systemctl enable kea-dhcp4-server
systemctl restart kea-dhcp4-server

echo "--- Habilitando y reiniciando Kea DHCPv6 ---"
systemctl enable kea-dhcp6-server
systemctl restart kea-dhcp6-server || echo "Aviso: DHCPv6 puede fallar si no hay subnets definidas"

# === Verificar estado de los servicios ===
echo "--- Estado del servicio Kea DHCP ---"
systemctl status kea-dhcp4-server --no-pager
systemctl status kea-dhcp6-server --no-pager

echo "--- DHCP configurado correctamente ---"
