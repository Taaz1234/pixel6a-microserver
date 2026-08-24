#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

# Montar subsistemas del kernel
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

# Configurar DNS
echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf

# Configurar grupos de red de Android dentro de Ubuntu
chroot $ROOTFS /bin/bash -c "
groupadd -g 3003 aid_inet 2>/dev/null || true
groupadd -g 3004 aid_net_raw 2>/dev/null || true
groupadd -g 3005 aid_net_admin 2>/dev/null || true
usermod -aG aid_inet,aid_net_raw,aid_net_admin amp 2>/dev/null || true
"

# Probar conexión a internet como usuario amp
chroot $ROOTFS /bin/su amp -c "curl -I https://cdn-downloads.c7rs.com 2>&1"
