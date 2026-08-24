#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] 1. Limpiando procesos antiguos..."
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

echo "[+] 2. Preparando instancia ADS01 en /root/.ampdata/instances/ADS01..."
mkdir -p $ROOTFS/root/.ampdata/instances/ADS01
cd $ROOTFS/root/.ampdata/instances/ADS01

# Si no está extraído, extraer desde el zip
if [ ! -f ./AMP_Linux_aarch64 ]; then
    unzip -q -o $ROOTFS/root/.ampdata/Versions/Mainline/20260724.1/AMP_aarch64.zip -d . 2>/dev/null || true
fi
chmod +x ./AMP_Linux_aarch64 2>/dev/null || true

echo "[+] 3. Configurando AMPConfig.conf para puerto 8085..."
# Ejecutar inicialización con licencia
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export TMPDIR=/tmp
cd /root/.ampdata/instances/ADS01
./AMP_Linux_aarch64 +Webserver.Port 8085 +Webserver.IPBinding 0.0.0.0 +Core.Licencing.LicenceKey 83358a72-e26c-46c2-b8d6-377f71bef408 -configonly 2>/dev/null || true
"

# Asegurar Webserver.Port=8085
sed -i 's/Webserver\.Port=[0-9]*/Webserver.Port=8085/g' $ROOTFS/root/.ampdata/instances/ADS01/AMPConfig.conf 2>/dev/null || true
sed -i 's/Webserver\.IPBinding=.*/Webserver.IPBinding=0.0.0.0/g' $ROOTFS/root/.ampdata/instances/ADS01/AMPConfig.conf 2>/dev/null || true

echo "[+] 4. Arrancando Dashboard en puerto 8080..."
export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
nohup /data/data/com.termux/files/usr/bin/python3 /data/local/tmp/dashboard_web/dashboard_server.py > /data/local/tmp/dashboard.log 2>&1 &

echo "[+] 5. Arrancando CubeCoders AMP en puerto 8085..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export TMPDIR=/tmp
cd /root/.ampdata/instances/ADS01
nohup ./AMP_Linux_aarch64 > /root/.ampdata/instances/ADS01/amp_web.log 2>&1 &
"

echo "[+] 6. Esperando 5 segundos para comprobar puertos..."
sleep 5
netstat -tuln | grep -E "8080|8085"
