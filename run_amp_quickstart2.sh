#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

# Montar subsistemas del kernel
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

# Configurar DNS y permisos
echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
chmod 777 $ROOTFS/tmp

# Ejecutar QuickStart como usuario amp
chroot $ROOTFS su - amp -c "export PATH=/usr/local/bin:/opt/cubecoders/amp:$PATH; ampinstmgr QuickStart admin Paco3421 0.0.0.0 8085"
