#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Creando instancia Minecraft01 via ampinstmgr..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp
cd /root

ampinstmgr --CreateInstance Minecraft Minecraft01 0.0.0.0 25565 '83358a72-e26c-46c2-b8d6-377f71bef408' admin Paco3421
"
