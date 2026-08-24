#!/bin/sh
# ==============================================================================
# AMP Supervisor & Auto-Restart Watchdog
# Mantiene CubeCoders AMP siempre corriendo y lo reinicia si el usuario
# pulsa "Restart" dentro del panel web.
# ==============================================================================

ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

# Montar subsistemas del kernel si no estan montados
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf

while true; do
    echo "[+] Iniciando instancia AMP..."
    chroot $ROOTFS /bin/bash -c "
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export HOME=/root
    export TMPDIR=/tmp
    cd /root/.ampdata/instances/ADS01
    ./AMP_Linux_aarch64 > /root/.ampdata/instances/ADS01/amp_web.log 2>&1
    "
    echo "[!] AMP ha terminado/reiniciado. Reanudando en 2 segundos..."
    sleep 2
done
