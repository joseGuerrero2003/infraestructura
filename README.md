# Infraestructura - Demo en GitHub Codespaces

Objetivo: desplegar rápidamente una demo funcional dentro de GitHub Codespaces que permita demostrar DNS, DHCP, FreeRADIUS y Prometheus/monitoring de forma simulada y segura.

Resumen rápido:
- Abrir este repositorio en Codespaces.
- Esperar a que el `devcontainer` se construya (instala Docker y herramientas básicas).
- Ejecutar `docker compose up --build -d` para levantar los servicios simulados.

Contenido creado/añadido:
- `.devcontainer/` : configuración para Codespaces con Docker instalado.
- `docker-compose.yml` : orquesta los servicios de demo.
- `docker/sim/` : imagen ligera (Flask) que simula DHCP, FreeRADIUS y exporta métricas Prometheus.
- `monitoring/prometheus_codespaces.yml` : configuración de Prometheus para la demo.

Servicios que levanta la demo:
- DNS (Bind9) - mapeado al puerto `1053` en el Codespace (uso `dig` con puerto 1053 para probar).
- DHCP (simulado) - HTTP en `8001` (endpoint `/leases` y métricas `/metrics`).
- FreeRADIUS (simulado) - HTTP en `8002` (endpoint `/auth` y métricas `/metrics`).
- Metrics simulator - HTTP en `8003` (endpoint `/metrics`).
- Prometheus - Web UI en `9090`.

Pasos detallados para la demostración en clase
1) Abrir el repositorio en GitHub Codespaces
   - Usa el botón "Code -> Open with Codespaces" en GitHub.
   - Codespaces abrirá y construirá el devcontainer usando `.devcontainer/Dockerfile` y `devcontainer.json`.

2) Construir y arrancar la demo
   - Abrir un terminal integrado en Codespaces y ejecutar:

```bash
docker compose up --build -d
```

3) Verificar servicios
- DNS (Bind):
  - Probar con dig desde el Codespace (usa TCP/puerto 1053):

```bash
dig @127.0.0.1 -p 1053 example.com +noall +answer
```

- DHCP (simulado):
  - Ver leases (simulado):

```bash
curl http://127.0.0.1:8001/leases
```

  - Ver logs para observar eventos simulados:

```bash
docker logs -f infra_dhcp_sim
```

- FreeRADIUS (simulado):

```bash
curl "http://127.0.0.1:8002/auth?user=alumno"
```

- Prometheus:
  - Abrir el puerto `9090` desde Codespaces (Ports view) o usar el navegador integrado: `http://127.0.0.1:9090`.
  - En Prometheus -> Status -> Targets debe aparecer `metrics_sim:8000`, `dhcp_sim:8000`, `radius_sim:8000` como UP.

Limitaciones y notas importantes
- UDP: GitHub Codespaces no expone puertos UDP públicamente; por eso Bind está mapeado a `1053` y recomendamos usar `dig` con la opción `+tcp` o especificando el puerto. Para demostraciones reales (respuestas sobre UDP/DHCP en red física) necesitarás desplegar en un host con acceso a la red (VM o servidor con capacidad CAP_NET_ADMIN).
- DHCP real: en este demo DHCP está simulado (no asigna IPs en la red del Codespace). Para operar DHCP real necesitas privilegios de red/host y típicamente ejecutar Kea o isc-dhcp con capacidades de red en una máquina dedicada/VM.
- FreeRADIUS real: aquí está simulado; una demo real requeriría ejecutar `freeradius` y usar clientes RADIUS para autenticar.

Siguientes pasos recomendados (documentados en el README para continuar después de la demo):
- Desplegar Kea DHCP real en una VM o en una máquina con Docker y CAP_NET_ADMIN.
- Desplegar FreeRADIUS real usando la imagen oficial o instalando desde paquetes y mapear `clients.conf` y `users`.
- Crear manifiestos `k8s/` para migrar los servicios a Kubernetes y preparar `LibreNMS` (documentado en esta rama más adelante).

Comandos rápidos de limpieza

```bash
docker compose down
```

Ayuda y diagnóstico
- Si `docker compose up` falla en Codespaces: abrir el panel "Terminal" y revisar la salida del `postCreateCommand` en la vista de "Dev Containers". Asegurar que el socket de Docker está accesible (`/var/run/docker.sock`).
- Si Prometheus no encuentra targets, revisar `docker logs infra_prometheus` y los logs de `infra_metrics`.

Si quieres, procedo ahora a levantar la demo en este Codespace (construir y ejecutar). ¿Lo hago ahora? (Puedo ejecutar `docker compose up --build -d` y luego mostrar cómo probar cada servicio.)
