#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "=========================================================="
echo "    INSTALANDO DEPENDENCIAS DE CUBECODERS AMP EN UBUNTU   "
echo "=========================================================="

apt-get update -y
apt-get install -y curl wget git tmux socat unzip sudo ca-certificates gnupg libicu-dev libssl3 openjdk-21-jre-headless jq

# 1. Crear usuario amp si no existe
if ! id -u amp >/dev/null 2>&1; then
    echo "[+] Creando usuario dedicado 'amp'..."
    useradd -m -d /home/amp -s /bin/bash amp
    echo "amp:amp" | chpasswd
    usermod -aG sudo amp
fi

# 2. Agregar repositorio oficial de CubeCoders
echo "[+] Agregando repositorio oficial de CubeCoders..."
mkdir -p /usr/share/keyrings
curl -fsSL https://repo.cubecoders.com/archive.key | gpg --dearmor --yes -o /usr/share/keyrings/cubecoders.gpg
echo "deb [signed-by=/usr/share/keyrings/cubecoders.gpg] https://repo.cubecoders.com/ debian/" > /etc/apt/sources.list.d/cubecoders.list

apt-get update -y
echo "[+] Instalando ampinstmgr..."
apt-get install -y ampinstmgr

echo "=========================================================="
echo "    AMPINSTMGR INSTALADO CON ÉXITO                         "
echo "=========================================================="
ampinstmgr --version || true
