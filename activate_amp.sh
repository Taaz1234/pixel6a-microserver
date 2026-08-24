#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

# Montar subsistemas del kernel
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf

mkdir -p $ROOTFS/tmp $ROOTFS/data/local/tmp
chmod 1777 $ROOTFS/tmp $ROOTFS/data/local/tmp

echo "[+] Activando CubeCoders AMP con tu clave de licencia..."

chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp

cd /root
ampinstmgr -nocache CreateInstance ADS ADS01 0.0.0.0 8085 83358a72-e26c-46c2-b8d6-377f71bef408 admin Paco3421
"
