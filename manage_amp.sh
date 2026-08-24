#!/bin/sh
# ==============================================================================
# Gestor de CubeCoders AMP en Pixel 6a (Ubuntu 24.04 ARM64 Chroot)
# ==============================================================================

ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

mount_chroot() {
    mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
    mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
    mount -t proc proc $ROOTFS/proc 2>/dev/null || true
    mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
    echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
    echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf
    mkdir -p $ROOTFS/tmp $ROOTFS/data/local/tmp $ROOTFS/root/.ampdata/instances/ADS01
    chmod 1777 $ROOTFS/tmp $ROOTFS/data/local/tmp
}

case "$1" in
    start)
        echo "[+] Montando subsistemas e iniciando CubeCoders AMP..."
        mount_chroot
        chroot $ROOTFS /bin/bash -c "
            export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
            export HOME=/root
            export TMPDIR=/tmp
            export TEMP=/tmp
            export TMP=/tmp
            cd /root/.ampdata/instances/ADS01
            nohup ./AMP_Linux_aarch64 +Webserver.Port 8085 +Webserver.IPBinding 0.0.0.0 > /root/.ampdata/instances/ADS01/amp_web.log 2>&1 &
        "
        sleep 2
        echo "[+] CubeCoders AMP iniciado en puerto 8085"
        ;;
    stop)
        echo "[+] Deteniendo CubeCoders AMP..."
        pkill -9 AMP_Linux_aarch64 2>/dev/null || true
        echo "[+] Proceso detenido."
        ;;
    status)
        echo "=== ESTADO DE CUBECODERS AMP ==="
        netstat -tuln 2>/dev/null | grep 8085 || echo "Puerto 8085 no activo"
        ps -ef 2>/dev/null | grep AMP_Linux_aarch64 | grep -v grep || echo "No hay proceso AMP corriendo"
        ;;
    logs)
        chroot $ROOTFS cat /root/.ampdata/instances/ADS01/amp_web.log 2>/dev/null || echo "No hay logs disponibles"
        ;;
    create)
        LICENSE_KEY="$2"
        if [ -z "$LICENSE_KEY" ]; then
            echo "Uso: $0 create <CLAVE_DE_LICENCIA>"
            exit 1
        fi
        echo "[+] Provisionando instancia ADS01 con tu clave de licencia..."
        mount_chroot
        chroot $ROOTFS /bin/bash -c "
            export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
            export HOME=/root
            export TMPDIR=/tmp
            export TEMP=/tmp
            export TMP=/tmp
            cd /root
            ampinstmgr -nocache CreateInstance ADS ADS01 0.0.0.0 8085 '$LICENSE_KEY' admin Paco3421
            ampinstmgr StartInstance ADS01
        "
        ;;
    *)
        echo "Uso: $0 {start|stop|status|logs|create <licence_key>}"
        exit 1
        ;;
esac
