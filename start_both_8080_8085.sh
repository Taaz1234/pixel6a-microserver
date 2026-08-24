#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] 1. Asegurando que Dashboard esta activo en 8080..."
if ! pgrep -f "dashboard_server.py" > /dev/null; then
    export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
    nohup /data/data/com.termux/files/usr/bin/python3 /data/local/tmp/dashboard_web/dashboard_server.py > /data/local/tmp/dashboard.log 2>&1 &
fi

echo "[+] 2. Asegurando que AMP esta activo en 8085..."
if ! pgrep -f "AMP_Linux_aarch64" > /dev/null; then
    mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
    mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
    mount -t proc proc $ROOTFS/proc 2>/dev/null || true
    mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
    echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf

    chroot $ROOTFS /bin/bash -c "
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export HOME=/root
    export TMPDIR=/tmp
    cd /root/.ampdata/instances/ADS01
    nohup ./AMP_Linux_aarch64 > /root/.ampdata/instances/ADS01/amp_web.log 2>&1 &
    "
fi

sleep 4
echo "=== ESTADO DE PUERTOS ==="
netstat -tuln | grep -E "8080|8085"
