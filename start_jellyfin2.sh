#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Instalando herramientas del sistema (procps, coreutils)..."
chroot $ROOTFS /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
apt-get update
apt-get install -y --no-install-recommends procps coreutils
"

echo "[+] Lanzando Jellyfin Server..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
/usr/local/bin/run_jellyfin.sh > /var/log/jellyfin/stdout.log 2>&1 &
"

sleep 5

echo "=== ESTADO DE JELLYFIN Y LOGS ==="
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
tail -n 25 /var/log/jellyfin/stdout.log
"

netstat -tuln | grep 8096 || true
