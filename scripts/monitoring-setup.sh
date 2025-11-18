#!/bin/bash
docker run -d -p 9090:9090 -v monitoring/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
docker run -d -p 3000:3000 grafana/grafana
