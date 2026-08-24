#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Instalando Playit.gg (Túnel y Dominio Anti-DDoS para Minecraft)..."

# Configurar repositorio oficial de Playit
chroot $ROOTFS /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/playit.gpg --yes
echo \"deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./\t\" > /etc/apt/sources.list.d/playit-cloud.list

apt-get update
apt-get install -y --no-install-recommends playit

echo '--- Comprobando binario de playit ---'
which playit
"
