#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Instalando OpenJDK 25 (Class file 69.0) y OpenJDK 17 en Ubuntu chroot..."

# Asegurar montaje de proc y dev para apt
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

chroot $ROOTFS /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo 'nameserver 1.1.1.1' > /etc/resolv.conf

apt-get update
apt-get install -y --no-install-recommends openjdk-25-jre-headless openjdk-17-jre-headless

echo '--- Versiones de Java instaladas ---'
update-java-alternatives --list || true

echo '--- Java por defecto actual ---'
java -version 2>&1
"
