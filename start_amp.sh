#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

# Montar subsistemas del kernel
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf

# Iniciar AMP en segundo plano en el puerto 8085
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
cd /root/.ampdata/instances/ADS01
nohup ./AMP_Linux_aarch64 +Webserver.Port 8085 +Webserver.IPBinding 0.0.0.0 > /root/.ampdata/instances/ADS01/amp_web.log 2>&1 &
"

sleep 3
# Verificar log
chroot $ROOTFS cat /root/.ampdata/instances/ADS01/amp_web.log
