#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Instalando su wrapper en chroot..."

# Respaldar su real si no está respaldado
if [ ! -f $ROOTFS/usr/bin/su.real ]; then
    cp $ROOTFS/usr/bin/su $ROOTFS/usr/bin/su.real 2>/dev/null || true
fi

cp /data/local/tmp/su_wrapper.sh $ROOTFS/usr/bin/su
chmod 755 $ROOTFS/usr/bin/su
cp /data/local/tmp/su_wrapper.sh $ROOTFS/bin/su 2>/dev/null || true

echo "[+] Probando su wrapper en chroot..."
chroot $ROOTFS /bin/bash -c "
su amp -c 'echo SU_WRAPPER_TEST_OK'
"

echo "[+] Limpiando instancia previa Minecraft01..."
rm -rf $ROOTFS/root/.ampdata/instances/Minecraft01

echo "[+] Probando creacion de instancia Minecraft con ampinstmgr..."
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -o bind /dev/pts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp
cd /root

ampinstmgr --CreateInstance Minecraft Minecraft01 0.0.0.0 25565 '83358a72-e26c-46c2-b8d6-377f71bef408' admin Paco3421
"
