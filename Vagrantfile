# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
UBUNTU_BOX = "ubuntu/focal64" # Imagen de uso para todos los nodos
PRIMARY_DOMAIN = "servicios.local"

# Prefijo IPv6
IPV6_PREFIX = "fd00:cafe:beef"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # --- Deshabilitar vagrant-vbguest ---
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  # --- Configuración General VirtualBox ---
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "1"
  end

  # --- Carpetas compartidas ---
  # Compartir la carpeta del proyecto con permisos adecuados
  config.vm.synced_folder ".", "/vagrant",
    owner: "vagrant",
    group: "vagrant",
    mount_options: ["dmode=755", "fmode=755"]

  #                     CONFIG SERVIDORES
  # =======================================================

  # 1. Servidor DNS Primario
  config.vm.define "dns-primary" do |dns_primary|
    dns_primary.vm.box = UBUNTU_BOX
    dns_primary.vm.hostname = "ns1.#{PRIMARY_DOMAIN}"
    dns_primary.vm.network "private_network", ip: "192.168.50.2"
    dns_primary.vm.provision "shell", inline: <<-SHELL
      echo "Provisioning DNS Primary (ns1.#{PRIMARY_DOMAIN})..."
      /vagrant/scripts/bootstrap.sh #{IPV6_PREFIX}::2 ns1.#{PRIMARY_DOMAIN}
      /vagrant/scripts/dns-primary-setup.sh
    SHELL
  end

  # 2. Servidor DNS Secundario
  config.vm.define "dns-secondary" do |dns_secondary|
    dns_secondary.vm.box = UBUNTU_BOX
    dns_secondary.vm.hostname = "ns2.#{PRIMARY_DOMAIN}"
    dns_secondary.vm.network "private_network", ip: "192.168.50.3"
    dns_secondary.vm.provision "shell", inline: <<-SHELL
      echo "Provisioning DNS Secondary (ns2.#{PRIMARY_DOMAIN})..."
      /vagrant/scripts/bootstrap.sh #{IPV6_PREFIX}::3 ns2.#{PRIMARY_DOMAIN}
      /vagrant/scripts/dns-secondary-setup.sh
    SHELL
  end

  # 3. Servidor DHCP
  config.vm.define "dhcp" do |dhcp_server|
    dhcp_server.vm.box = UBUNTU_BOX
    dhcp_server.vm.hostname = "dhcp.#{PRIMARY_DOMAIN}"
    dhcp_server.vm.network "private_network", ip: "192.168.50.4"
    dhcp_server.vm.provision "shell", inline: <<-SHELL
      echo "Provisioning DHCP Server (dhcp.#{PRIMARY_DOMAIN})..."
      /vagrant/scripts/bootstrap.sh #{IPV6_PREFIX}::4 dhcp.#{PRIMARY_DOMAIN}
      /vagrant/scripts/dhcp-setup.sh
    SHELL
  end

  # 4. Servidor FreeRADIUS
  config.vm.define "freeradius" do |radius|
    radius.vm.box = UBUNTU_BOX
    radius.vm.hostname = "freeradius.#{PRIMARY_DOMAIN}"
    radius.vm.network "private_network", ip: "192.168.50.5"
    radius.vm.provision "shell", inline: <<-SHELL
      echo "Provisioning FreeRADIUS (freeradius.#{PRIMARY_DOMAIN})..."
      /vagrant/scripts/bootstrap.sh #{IPV6_PREFIX}::5 freeradius.#{PRIMARY_DOMAIN}
      /vagrant/scripts/freeradius-setup.sh
    SHELL
  end

  # 5. Servidor LibreQoS
  config.vm.define "libreqos" do |qos|
    qos.vm.box = UBUNTU_BOX
    qos.vm.hostname = "libreqos.#{PRIMARY_DOMAIN}"
    qos.vm.network "private_network", ip: "192.168.50.7"
    qos.vm.provision "shell", inline: <<-SHELL
      echo "Provisioning LibreQoS (libreqos.#{PRIMARY_DOMAIN})..."
      /vagrant/scripts/bootstrap.sh #{IPV6_PREFIX}::7 libreqos.#{PRIMARY_DOMAIN}
      /vagrant/scripts/libreqos-setup.sh
    SHELL
  end

  #                     CONFIG CLIENTES
  # =======================================================

  # Cliente 1
  config.vm.define "client1" do |client|
    client.vm.box = UBUNTU_BOX
    client.vm.hostname = "client1.#{PRIMARY_DOMAIN}"
    client.vm.network "private_network", type: "dhcp"
    client.vm.provision "shell", path: "scripts/client-setup.sh"
  end

  # Cliente 2
  config.vm.define "client2" do |client|
    client.vm.box = UBUNTU_BOX
    client.vm.hostname = "client2.#{PRIMARY_DOMAIN}"
    client.vm.network "private_network", type: "dhcp"
    client.vm.provision "shell", path: "scripts/client-setup.sh"
  end

end
