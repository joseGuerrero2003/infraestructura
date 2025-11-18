#!/bin/bash
set -eux  # Exit on error, print commands

# Argumentos esperados: IPv6 y Hostname completo
EXPECTED_IPV6_ADDRESS=$1    # Ej: fd00:cafe:beef::4
HOSTNAME_FQDN=$2            # Ej: dhcp.servicios.local
PRIMARY_DOMAIN="servicios.local"

echo "--- Running bootstrap.sh for ${HOSTNAME_FQDN} ---"
echo "Target IPv6: ${EXPECTED_IPV6_ADDRESS}"

# Evitar prompts de timezone
export DEBIAN_FRONTEND=noninteractive
sudo ln -fs /usr/share/zoneinfo/America/Bogota /etc/localtime
sudo apt-get update -y
sudo apt-get install -y tzdata
sudo dpkg-reconfigure --frontend noninteractive tzdata

# Actualizar paquetes
sudo apt-get update -y
sudo apt-get install -y vim net-tools dnsutils curl wget ca-certificates ufw software-properties-common chrony

# Configurar hostname
echo "${HOSTNAME_FQDN}" | sudo tee /etc/hostname
SHORT_HOSTNAME=$(echo "${HOSTNAME_FQDN}" | cut -d. -f1)
sudo sed -i "/127.0.1.1/d" /etc/hosts
echo "127.0.1.1 ${HOSTNAME_FQDN} ${SHORT_HOSTNAME}" | sudo tee -a /etc/hosts

# Asignación de IPs estáticas para todos los servidores del proyecto
sudo sed -i '/# Server IPs for proyectos/,/# End Server IPs/d' /etc/hosts
cat <<EOF | sudo tee -a /etc/hosts
# Server IPs for proyectos
192.168.50.2   ns1.${PRIMARY_DOMAIN} ns1
fd00:cafe:beef::2 ns1.${PRIMARY_DOMAIN} ns1
192.168.50.3   ns2.${PRIMARY_DOMAIN} ns2
fd00:cafe:beef::3 ns2.${PRIMARY_DOMAIN} ns2
192.168.50.4   dhcp.${PRIMARY_DOMAIN} dhcp
fd00:cafe:beef::4 dhcp.${PRIMARY_DOMAIN} dhcp
192.168.50.5   freeradius.${PRIMARY_DOMAIN} freeradius
fd00:cafe:beef::5 freeradius.${PRIMARY_DOMAIN} freeradius
192.168.50.7   libreqos.${PRIMARY_DOMAIN} libreqos
fd00:cafe:beef::7 libreqos.${PRIMARY_DOMAIN} libreqos
# End Server IPs
EOF

# Detectar interfaz de red privada (192.168.50.x)
DETECTED_PRIVATE_INTERFACE=$(ip -4 addr show | grep -oP 'inet 192\.168\.50\.\d+/\d+.* brd \d+\.\d+\.\d+\.\d+ scope global \K[a-zA-Z0-9]+')
if [ -z "$DETECTED_PRIVATE_INTERFACE" ]; then
    echo "ERROR: No se detectó interfaz privada. Usando fallback..."
    DETECTED_PRIVATE_INTERFACE=$(ip -o link show | awk -F': ' '$2 !~ /lo|vir|docker|veth|br-/{print $2; exit_status=NR; if(exit_status==2) exit}' | head -n1)
    if [ -z "$DETECTED_PRIVATE_INTERFACE" ]; then
        echo "ERROR: Falla total al detectar interfaz privada. Abortando."
        exit 1
    fi
    echo "Interfaz detectada por fallback: $DETECTED_PRIVATE_INTERFACE"
fi
echo "Interfaz privada detectada: $DETECTED_PRIVATE_INTERFACE"

# Asignar IPv6
echo "Asignando IPv6 ${EXPECTED_IPV6_ADDRESS}/64 a ${DETECTED_PRIVATE_INTERFACE}"
sudo ip addr add "${EXPECTED_IPV6_ADDRESS}/64" dev "${DETECTED_PRIVATE_INTERFACE}"

# Persistencia de IPv6 vía netplan
NETPLAN_FILE_PATH=""
if ls /etc/netplan/*vagrant*.yaml 1> /dev/null 2>&1; then
    NETPLAN_FILE_PATH=$(sudo ls /etc/netplan/*vagrant*.yaml | head -n 1)
elif ls /etc/netplan/*.yaml 1> /dev/null 2>&1; then
    NETPLAN_FILE_PATH=$(sudo ls /etc/netplan/*.yaml | head -n 1)
fi
if [ -n "$NETPLAN_FILE_PATH" ]; then
    echo "Modificando netplan: $NETPLAN_FILE_PATH"
    if sudo grep -qP "^\s*${DETECTED_PRIVATE_INTERFACE}:" "$NETPLAN_FILE_PATH"; then
        sudo sed -i "/^\s*${DETECTED_PRIVATE_INTERFACE}:/,/^\s*[a-zA-Z0-9]\+:/ { /${EXPECTED_IPV6_ADDRESS}\/64/d; }" "$NETPLAN_FILE_PATH"
        if sudo awk "/^ *${DETECTED_PRIVATE_INTERFACE}:/,/^ *[a-zA-Z0-9]+:/" "$NETPLAN_FILE_PATH" | grep -q "addresses:"; then
            sudo sed -i "/^\s*${DETECTED_PRIVATE_INTERFACE}:/,/addresses:/s|\(addresses:\)|\1\n        - ${EXPECTED_IPV6_ADDRESS}/64|" "$NETPLAN_FILE_PATH"
        else
            sudo sed -i "/^\s*${DETECTED_PRIVATE_INTERFACE}:/a \      addresses:\n        - ${EXPECTED_IPV6_ADDRESS}/64" "$NETPLAN_FILE_PATH"
        fi
    else
        echo "Sección no encontrada, creando nueva..."
        cat <<EOF | sudo tee -a "$NETPLAN_FILE_PATH"

    ${DETECTED_PRIVATE_INTERFACE}:
      addresses:
        - ${EXPECTED_IPV6_ADDRESS}/64
EOF
    fi
    sudo netplan apply
else
    echo "No se encontró archivo netplan. La IPv6 será temporal."
fi

# Configuración NTP (Chrony)
sudo systemctl enable chrony
sudo systemctl start chrony

# Configuración básica de UFW
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "--- bootstrap.sh para ${HOSTNAME_FQDN} completado ---"
