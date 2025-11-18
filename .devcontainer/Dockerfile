FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    docker.io \
    docker-compose-plugin \
    iputils-ping \
    dnsutils \
    curl \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
