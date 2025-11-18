# Infraestructura - Demo en GitHub Codespaces

Este repositorio contiene una colección de configuraciones y scripts para servicios de infraestructura (DNS, DHCP, FreeRADIUS, monitoreo) originalmente preparados para un laboratorio con Vagrant y máquinas virtuales. Debido a limitaciones de recursos en máquinas locales, se adaptó la demostración para ejecutarse en GitHub Codespaces usando contenedores Docker y servicios simulados. El objetivo es poder presentar y validar la funcionalidad de los servicios de forma rápida, segura y reproducible en una sesión de clase.

------

**Resumen ejecutivo (qué hice y por qué)**

- Inicialmente el laboratorio se diseñó usando `Vagrant` y múltiples VMs (ver `Vagrantfile` y `configs/`). Esto es ideal para entornos de red real pero exige mucha memoria/CPU.
- Para poder demostrar en entornos con recursos limitados (como el escenario de clase), migré la demo a `Codespaces` con un `devcontainer` que contiene Docker. Los servicios principales (DNS, DHCP, RADIUS) se simulan con un servicio ligero en Python que además exporta métricas Prometheus.
- Esta migración permite: reproducibilidad, menor consumo de recursos, menor riesgo de alterar redes locales y obtener métricas observables con Prometheus.

------

**Qué hay en este repositorio (navegación rápida)**

- `Vagrantfile` + `configs/` : configuración original para despliegue con Vagrant/VirtualBox (múltiples VMs para DNS primario/secundario, DHCP, FreeRADIUS, clientes, etc.).
- `.devcontainer/` : configuración para GitHub Codespaces (instala docker, herramientas y monta `docker.sock`).
- `docker-compose.yml` : orquesta los servicios de demo para Codespaces (simuladores y Prometheus).
- `docker/sim/` : imagen ligera con `sim_service.py` (Flask) que simula endpoints y exporta métricas Prometheus.
- `monitoring/prometheus_codespaces.yml` : configuración de Prometheus usada en la demo.
- `freeradius/`, `configs/dhcp`, `configs/dns-primary/` : archivos de configuración reales que pueden usarse para desplegar servicios verdaderos en entornos con permisos de red.

------

Arquitectura de la demo (simplificada)

- `infra_dns_sim` (simulador TCP): responde a consultas simples y expone métricas.
- `infra_dhcp_sim` (simulador): expone la configuración de DHCP y métricas de leases.
- `infra_radius_sim` (simulador): expone endpoint de autenticación `/auth` y métricas de autenticaciones.
- `infra_metrics` (agregador simulado): servicio que mantiene métricas combinadas para la demo.
- `infra_prometheus` (Prometheus): scrapea las métricas expuestas por los simuladores y permite visualización.

Los servicios están definidos en `docker-compose.yml` para ejecutar todo dentro del Codespace con puertos mapeados hacia localhost.

------

Guía de uso — pasos para la demostración en clase

1) Abrir el repositorio en GitHub Codespaces
   - En GitHub, usar "Code -> Open with Codespaces".
   - Esperar a que el devcontainer se construya. El `postCreateCommand` instala `docker` y utilidades.

2) Levantar la demo
   - En el terminal integrado del Codespace (raíz del repo):

```bash
docker compose up --build -d
```

3) Verificar que los contenedores estén corriendo

```bash
docker ps
```

4) Probar los servicios (comandos rápidos)

- DNS (simulado, HTTP/TCP):
  ```bash
  curl http://127.0.0.1:1053/
  # (si instalas dnsutils en el devcontainer, puedes usar dig con TCP)
  dig +tcp @127.0.0.1 -p 1053 example.com
  ```

- DHCP (simulado):
  ```bash
  curl http://127.0.0.1:8001/leases
  docker logs -f infra_dhcp_sim
  ```

- FreeRADIUS (simulado):
  ```bash
  curl "http://127.0.0.1:8002/auth?user=alumno"
  ```

- Métricas y Prometheus:
  - Abrir `http://127.0.0.1:9090` (Ports view si necesitas publicar puerto desde Codespaces).
  - En Prometheus → Status → Targets verás `metrics_sim`, `dhcp_sim` y `radius_sim` como UP.
  - Consultas de ejemplo: `dns_queries_total`, `dhcp_leases_active`, `radius_auth_success_total`.

5) Parar y limpiar:

```bash
docker compose down
```

------

Explicación técnica y pedagógica (qué estamos demostrando)

- DNS: el servicio DNS traduce nombres a direcciones. En el laboratorio original se usan zonas maestras y DNSSEC; en la demo de Codespaces usamos un simulador que ilustra respuestas y exporta métricas.
- DHCP: protocolo para asignación dinámica de direcciones IP. En el entorno real, Kea o isc-dhcp atienden sobre UDP/67-68 — sin embargo Codespaces impide manipular la red host, por lo que usamos una simulación que muestra la configuración de subredes y leases.
- FreeRADIUS: servidor de autenticación para redes (802.1X, etc.). La demo simula peticiones de autentificación (`Access-Accept` / `Access-Reject`) y contabiliza éxitos para Prometheus.
- Observabilidad (Prometheus): recopilamos métricas de los servicios simulados para mostrar cómo monitorizar disponibilidad, tráfico y éxito/fracaso de operaciones.

Esta aproximación (simuladores + Prometheus) facilita explicar los conceptos sin depender de privilegios o topologías de red complejas.

------

Limitaciones y cómo realizar una demo 'real' completa

- UDP y privilegios de red: para que DHCP y DNS funcionen de forma nativa en la red (clientes obteniendo IPs, DNS sobre UDP), necesitas un host/VM con capacidad de manipular interfaces de red (CAP_NET_ADMIN) o desplegar en hardware/VM en la nube.
- Recomendación para demo real:
  1. Reservar una VM (cloud provider o máquina local) con permisos para ejecutar contenedores con capacidades de red.
  2. Desplegar Kea DHCP y Bind9/FreeRADIUS reales usando las configuraciones en `configs/` y `freeradius/`.
  3. Probar con clientes reales en la misma red o mediante VLANs/segmentación.

------
