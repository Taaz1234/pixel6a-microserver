#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Lanzando Playit para generar el enlace de reclamo..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
/usr/local/bin/playit > /tmp/playit_claim.log 2>&1 &
"

sleep 4

echo "=== SALIDA DE PLAYIT ==="
chroot $ROOTFS /bin/bash -c "
cat /tmp/playit_claim.log
"
