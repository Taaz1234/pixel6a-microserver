#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Verificando repositorios y dependencias para Jellyfin en arm64..."

mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

# Asegurar enlace a /sdcard/Media dentro del chroot
mkdir -p $ROOTFS/media/Media
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true

chroot $ROOTFS /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo 'nameserver 1.1.1.1' > /etc/resolv.conf

# Instalar prerequisitos: curl, gnupg, lsb-release
apt-get update
apt-get install -y --no-install-recommends curl gnupg lsb-release ca-certificates

# Configurar repositorio oficial de Jellyfin
mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg --yes

VERSION_CODENAME=\$(lsb_release -cs)
echo \"deb [arch=arm64 signed-by=/etc/apt/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu \${VERSION_CODENAME} main\" > /etc/apt/sources.list.d/jellyfin.list

apt-get update
apt-cache search jellyfin
"
