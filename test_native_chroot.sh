#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu"

# Montar subsistemas del kernel nativo
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

# Configurar DNS en el rootfs
echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf

# Ejecutar ampinstmgr con chroot nativo
chroot $ROOTFS /bin/bash -c "export DOTNET_GCHeapHardLimit=0x40000000; ampinstmgr --version"
