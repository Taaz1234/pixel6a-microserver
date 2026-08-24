#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

mkdir -p $ROOTFS/tmp/pixelmmo_source
cp -r /data/local/tmp/pixelmmo_source/* $ROOTFS/tmp/pixelmmo_source/ 2>/dev/null || true
cp /data/local/tmp/build_and_deploy_mmo.sh $ROOTFS/tmp/build_and_deploy_mmo.sh
chmod 755 $ROOTFS/tmp/build_and_deploy_mmo.sh

echo "=== EJECUTANDO COMPILACION DENTRO DEL CONTENEDOR ==="
chroot $ROOTFS /bin/bash /tmp/build_and_deploy_mmo.sh
