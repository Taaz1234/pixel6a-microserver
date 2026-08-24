#!/bin/bash
set -e

echo "[+] Configurando repositorio CubeCoders aarch64..."
echo "deb [signed-by=/usr/share/keyrings/cubecoders.gpg] https://repo.cubecoders.com/aarch64/ /" > /etc/apt/sources.list.d/cubecoders.list

apt-get update -y
apt-get install -y ampinstmgr

echo "[+] Verificando instalación..."
ampinstmgr --version
