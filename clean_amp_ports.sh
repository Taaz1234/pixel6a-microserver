#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Deteniendo todos los procesos de AMP y Dashboard..."
pkill -9 -f AMP_Linux_aarch64 2>/dev/null || true
pkill -9 -f dashboard_server.py 2>/dev/null || true
sleep 1

# Montar subsistemas
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf

# Reconstruir instancia ADS01 en puerto 8085 limpio con admin / Paco3421 y licencia
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp

rm -rf /root/.ampdata/instances/ADS01 /root/.ampdata/instances.json
mkdir -p /root/.ampdata/instances/ADS01
cd /root/.ampdata/instances/ADS01

# Descargar/extraer Core si no esta
if [ ! -f ./AMP_Linux_aarch64 ]; then
    cp -r /opt/cubecoders/amp/* . 2>/dev/null || true
fi
"

echo "[+] Verificando puertos libres..."
netstat -tuln | grep -E "8080|8085" || echo "Puertos 8080 y 8085 liberados."
