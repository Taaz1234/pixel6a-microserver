#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Montando subsistemas del kernel..."
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf

echo "[+] Creando instancia Minecraft01 con ampinstmgr..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp
cd /root

ampinstmgr --CreateInstance Minecraft Minecraft01 0.0.0.0 25565 '83358a72-e26c-46c2-b8d6-377f71bef408' admin Paco3421
"
