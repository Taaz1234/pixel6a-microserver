#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

# Montar subsistemas
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf

chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
cd /root/.ampdata/instances/ADS01

# Ejecutar configuración y arranque con licencia
./AMP_Linux_aarch64 +Webserver.Port 8085 +Webserver.IPBinding 0.0.0.0 +Core.Licencing.LicenceKey 83358a72-e26c-46c2-b8d6-377f71bef408 +Core.Login.Username admin +Core.Login.Password Paco3421 -configonly

# Iniciar servidor web en segundo plano
nohup ./AMP_Linux_aarch64 +Webserver.Port 8085 +Webserver.IPBinding 0.0.0.0 > /root/.ampdata/instances/ADS01/amp_web.log 2>&1 &
"

sleep 3
# Mostrar logs iniciales
chroot $ROOTFS cat /root/.ampdata/instances/ADS01/amp_web.log
