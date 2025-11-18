# Guion de exposición: Proyecto "Infraestructura" (Demo en GitHub Codespaces)

Objetivo: disponer de un guion completo, slide-by-slide, con el contenido de cada diapositiva y las notas exactas para presentar este proyecto en clase. Incluye pasos de demo, comandos, justificación técnica, limitaciones y el prompt para Skywork AI que genere las diapositivas visuales.

Duración recomendada: 20–30 minutos (15 min presentación + 10–15 min demo + 5–10 min preguntas)

---

**Slide 1 — Título**
- Título: "Infraestructura: DNS, DHCP, FreeRADIUS y Observabilidad — Demo en Codespaces"
- Subtítulo: "Migración desde Vagrant a Codespaces para demos reproducibles"
- Autor: Tu nombre / Fecha

Notas del presentador (texto a decir):
"Buenos días/tardes. Soy [TU NOMBRE]. Hoy voy a presentar el proyecto 'Infraestructura', donde implementamos servicios de red (DNS, DHCP, FreeRADIUS) y observabilidad con Prometheus. Mostraremos una demo reproducible en GitHub Codespaces y explicaré la migración desde el laboratorio original con Vagrant."

---

**Slide 2 — Agenda**
- 1) Contexto y motivación
- 2) Arquitectura original (Vagrant)
- 3) Problemas y decisión de migración
- 4) Arquitectura en Codespaces (Docker + simuladores)
- 5) Demo práctica (comandos y resultados esperados)
- 6) Limitaciones y pasos para despliegue real
- 7) Próximos pasos: Kubernetes y LibreNMS
- 8) Preguntas

Notas:
"Esta es la hoja de ruta de la presentación — iré rápido en las secciones conceptuales y dedicaré tiempo a la demo para que vean el proyecto funcionando." 

---

**Slide 3 — Contexto y motivación**
- Objetivo del laboratorio: enseñar servicios de red y monitoreo operativos.
- Contenidos: DNS autoritativo, DHCP, FreeRADIUS (autenticación), Prometheus (métricas).
- Requisito pedagógico: reproducibilidad y bajo coste de recursos para presentaciones en aula.

Notas:
"El laboratorio fue concebido para practicar servicios reales. Sin embargo, ejecutar múltiples VMs consume memoria y CPU — lo que dificulta su uso en máquinas de estudiantes o para demostraciones rápidas. Por eso migramos a una solución basada en Codespaces y contenedores." 

---

**Slide 4 — Arquitectura original (Vagrant / VirtualBox)**
- VMs: `dns-primary`, `dns-secondary`, `dhcp`, `freeradius`, `libreqos`, `client1`, `client2`.
- Configs: `configs/` (named.conf, kea-dhcp, etc.), `freeradius/`.
- Ventajas: topología real, UDP/DHCP funcional, control total de red.
- Desventajas: alto consumo de recursos, complejidad para desplegar en clase.

Notas (breve demostración de evidencia del problema):
"En mi entorno local el uso de RAM subía a >10 GB y las VMs demoraban en arrancar. Imágenes en el anexo muestran varias VMs corriendo y la memoria casi saturada." 

---

**Slide 5 — Problemas detectados y decisión de migración**
- Recursos limitados en equipos de los alumnos y para presentaciones.
- Necesidad de seguridad y reproducibilidad (no tocar redes locales).
- Solución: migración a GitHub Codespaces + contenedores Docker, simuladores ligeros y Prometheus para observabilidad.

Notas:
"La decisión fue pragmática: mantener la lógica y configuración original dentro del repo, pero reemplazar las VMs por simuladores que demuestren el comportamiento y las métricas sin requerir privilegios de red." 

---

**Slide 6 — Arquitectura en Codespaces (alto nivel)**
- `devcontainer` monta `docker.sock` y provee Docker en el Codespace.
- `docker-compose.yml` orquesta:
  - `infra_dns_sim` — simulador DNS (TCP)
  - `infra_dhcp_sim` — simulador DHCP (HTTP + métricas)
  - `infra_radius_sim` — simulador FreeRADIUS (HTTP + métricas)
  - `infra_metrics` — servicio que agrega métricas (opcional)
  - `infra_prometheus` — Prometheus
- Configs reales almacenadas en `configs/` y `freeradius/` para referencia o despliegue real.

Notas:
"Esta arquitectura permite demostrar nombres, leases, autenticaciones y métricas con el mínimo coste y con la misma configuración base que usaríamos en el despliegue real." 

---

**Slide 7 — ¿Qué contiene el repositorio hoy? (mapa rápido)**
- `Vagrantfile` — configuración original con múltiples VMs.
- `configs/` — DNS, DHCP (kea), zonas, claves TSIG.
- `freeradius/` — `clients.conf`, `eap.conf`, `users`.
- `.devcontainer/` — `devcontainer.json`, `Dockerfile` (Codespaces).
- `docker-compose.yml` — orquestación de demo.
- `docker/sim/` — `sim_service.py`, Dockerfile (simulador Flask + metrics).
- `monitoring/prometheus_codespaces.yml` — config Prometheus.
- `README.md` y `PRESENTATION.md` (esta presentación).

Notas:
"Recomiendo abrir el repo y señalar estos archivos para que los evaluadores vean la relación entre la configuración original y la demo actual." 

---

**Slide 8 — Paso a paso: preparar Codespaces (rápido)**
Contenido de la diapositiva (bullet points):
- Abrir en GitHub → Code → Open with Codespaces.
- Esperar a que se construya el devcontainer.
- En terminal integrado: `docker compose up --build -d`.
- Verificar: `docker ps`, visitar `http://127.0.0.1:9090` para Prometheus.

Notas (texto para decir):
"Durante la demo ejecutaré exactamente esos comandos. El devcontainer instala Docker y herramientas; el compose levanta los simuladores y Prometheus." 

---

**Slide 9 — Comandos para la demo y resultados esperados (demo en vivo)**
- Levantar servicios:
  ```bash
  docker compose up --build -d
  ```
- Ver containers:
  ```bash
  docker ps
  ```
- Probar endpoints:
  ```bash
  curl http://127.0.0.1:1053/        # DNS sim
  curl http://127.0.0.1:8001/leases  # DHCP sim
  curl "http://127.0.0.1:8002/auth?user=alumno"  # RADIUS sim
  curl http://127.0.0.1:8003/metrics | head -n 20 # metrics
  ```
- Abrir Prometheus: `http://127.0.0.1:9090` → Status → Targets (deben estar UP)

Notas de la demo (guion exacto):
1. Ejecutar `docker compose up --build -d` y comentar la salida de build.
2. Mostrar `docker ps` y resaltar nombres de containers.
3. Ejecutar cada `curl` y leer la salida breve en voz alta: mostrar que `auth` devuelve `Access-Accept`, `leases` muestra configuración, `/metrics` expone `dns_queries_total`.
4. Abrir Prometheus en el browser embebido y mostrar Targets y una consulta simple (`dns_queries_total`) para ver métricas en tiempo real.

---

**Slide 10 — Observabilidad: Prometheus**
- Qué se mide: `dns_queries_total`, `dhcp_leases_active`, `radius_auth_success_total`.
- Por qué: validar disponibilidad del servicio, actividad y éxito de operaciones.
- Demo rápida: consulta `dns_queries_total` y mostrar gráfica.

Notas:
"Explico cómo Prometheus scrapea los endpoints y cómo estas métricas ayudan a diagnosticar problemas de servicio en producción." 

---

**Slide 11 — Limitaciones del enfoque y cómo hacer la demo 'real'**
- Limitaciones de Codespaces: no expone UDP, no permite CAP_NET_ADMIN — DHCP y DNS UDP no funcionarán como en red real.
- Para demo real (clientes recibiendo IPs y DNS por UDP) se necesita:
  - VM/host con permisos de red (cloud VM o servidor físico) o cluster con CNI que permita estas funciones.
  - Despliegue de `kea` / `bind9` / `freeradius` reales con las configuraciones en `configs/` y `freeradius/`.
- Pasos resumidos para producción:
  1. Provisionar VM con Docker (o usar K8s con `HostNetwork`/privilegios).
  2. Desplegar imágenes reales (Bind9, Kea, FreeRADIUS) y mapear configs.
  3. Realizar pruebas con clientes en la misma red física o mediante VLANs/segmentación.

Notas:
"Expón claramente que la demo en Codespaces es pedagógica y reproducible, y el camino a producción requiere un entorno con control de red." 

---

**Slide 12 — Siguientes pasos y roadmap (k8s, LibreNMS)**
- Migrar a Kubernetes: crear manifests en `k8s/` (simuladores primero, luego reales).
- Añadir Grafana + dashboards para métricas (visualización profesional).
- Desplegar LibreNMS para inventario y monitoreo de red; documentar integración con Prometheus.

Notas:
"Resalta que la base ya está en el repo y explicarás cómo proceder si se quiere transformar esto en un despliegue de laboratorio más avanzado." 

---

**Slide 13 — Resumen y conclusiones**
- Logros: reproducibilidad en Codespaces, demo completa de DNS/DHCP/RADIUS y observabilidad.
- Valor pedagógico: permite concentrarse en conceptos sin depender de hardware.
- Recomendación: usar Codespaces para enseñanza; usar VM/infraestructura real para prácticas de red avanzadas.

Notas (cierre):
"Con esto finalizo la parte expositiva. Ahora pasaré la demo en vivo — ejecutaré los comandos y responderé preguntas." 

---

**Slide 14 — Comandos Git y respaldo (apéndice operativo)**
- Comandos ejecutados para respaldo y push (recomendado leer antes de forzar pushes):
  ```bash
  git fetch origin
  git push --force origin origin/master:refs/heads/backup-remote-master  # crea respaldo remoto
  git add .
  git commit -m "Demo: configurar Codespaces y simuladores + README completo"
  git push --force origin master  # sobrescribe origin/master con local
  ```

Notas:
"Explica que siempre creamos una rama `backup-remote-master` antes de forzar el push para no perder historial remoto." 

---

**Slide 15 — Preguntas y contacto**
- GitHub repo: `https://github.com/joseGuerrero2003/infraestructura`
- Contacto: tu correo / GitHub handle

Notas:
"Invita a las preguntas y sugiere una demostración guiada para quien quiera replicarlo." 

---

Apéndice: Script de demostración recomendado (opcional para incluir en `scripts/demo.sh`)
```bash
#!/usr/bin/env bash
set -e
echo "Arrancando demo..."
docker compose up --build -d
echo "Containers:"
docker ps --filter name=infra_
echo "DNS sim root:" && curl -s http://127.0.0.1:1053/
echo "DHCP leases:" && curl -s http://127.0.0.1:8001/leases
echo "RADIUS auth:" && curl -s "http://127.0.0.1:8002/auth?user=alumno"
echo "Métricas sample:" && curl -s http://127.0.0.1:8003/metrics | sed -n '1,40p'
echo "Prometheus: http://127.0.0.1:9090"
```

---

Skywork AI — prompt para generar diapositivas (usa esto como prompt de entrada)

Prompt (en español, conciso y completo):

"Genera una presentación ejecutiva y profesional de 15 diapositivas en español para un proyecto académico llamado 'Infraestructura: DNS, DHCP, FreeRADIUS y Observabilidad — Demo en Codespaces'. La presentación debe incluir:
- Slide 1: Título con autor y fecha.
- Slide 2: Agenda clara.
- Slide 3: Contexto y motivación (explicar por qué hacemos esta demo).
- Slide 4: Arquitectura original con Vagrant (lista de VMs y problema de recursos).
- Slide 5: Problemas detectados y decisión de migración a Codespaces.
- Slide 6: Arquitectura en Codespaces (diagrama simple: devcontainer -> docker compose -> servicios).
- Slide 7: Contenido del repositorio (lista de archivos y propósito).
- Slide 8: Pasos para preparar Codespaces (commands brevity).
- Slide 9: Demo paso a paso con comandos y outputs esperados.
- Slide 10: Observabilidad con Prometheus (métricas clave).
- Slide 11: Limitaciones y cómo hacer la demo real en producción.
- Slide 12: Roadmap: k8s, LibreNMS, dashboards.
- Slide 13: Resumen y conclusiones.
- Slide 14: Apéndice operativo: comandos git para respaldo y push forzado (explicar precaución).
- Slide 15: Preguntas y contacto.

Para cada diapositiva, genera:
1) Título de la diapositiva.
2) 4–6 bullets cortos (máximo 2 líneas cada uno).
3) Notas del orador en español (máximo 120 palabras por diapositiva) con el guion exacto para leer en la presentación.
4) Sugerencia visual (iconos, diagramas, captura de pantalla recomendada).

Estilo: profesional, minimalista, paleta azul/gris, tipografía legible. Genera la salida en formato JSON con una lista de slides y campos: `title`, `bullets[]`, `speaker_notes`, `visual_suggestion`." 

Notas sobre Skywork prompt:
"Puedes pegar este prompt directamente en Skywork AI; ajusta el idioma si la IA lo solicita. El JSON resultante permite importación automática a herramientas de diseño o conversión a PowerPoint." 

---

Fin del guion. Si quieres, genero también `scripts/demo.sh` y lo añado al repo, o puedo generar la versión de slides en Markdown para que la importes en herramientas que acepten SLIDE-MD.
