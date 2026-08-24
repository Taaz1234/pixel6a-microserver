#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
ls -la /root/.ampdata/Versions/Mainline/*/ 2>/dev/null || true
mkdir -p /root/.ampdata/instances/ADS01
cd /root/.ampdata/instances/ADS01
if [ -f /root/.ampdata/Versions/Mainline/*/AMP_aarch64.zip ]; then
    echo '[+] Descomprimiendo AMP_aarch64.zip manualmente...'
    unzip -qo /root/.ampdata/Versions/Mainline/*/AMP_aarch64.zip
    echo '[+] Contenido de ADS01:'
    ls -la /root/.ampdata/instances/ADS01
fi
"
