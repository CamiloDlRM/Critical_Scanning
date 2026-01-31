#!/bin/bash
set -e

echo "=== Creacion de grupo y Usuario ==="

groupadd dockergrp
useradd -m -s /bin/bash -g dockergrp dockeruser


echo "=== Script de instalación de Docker en Ubuntu ==="

echo "=== Actualizando sistema ==="
apt-get update -y
apt-get upgrade -y

echo "=== Instalando dependencias ==="
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

echo "=== Agregando GPG key de Docker ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo "=== Agregando repositorio oficial de Docker ==="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

echo "=== Instalando Docker ==="
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "=== Iniciando y habilitando Docker ==="
systemctl start docker
systemctl enable docker

echo "=== Agregando usuario ubuntu al grupo docker ==="
usermod -aG docker dockeruser

echo "=== Verificando instalación ==="
docker --version
docker compose version

echo "=== Docker instalado correctamente en Ubuntu ==="