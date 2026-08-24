#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Probando provision de Minecraft01 con +Core.AMP.ModuleName Minecraft..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export TMPDIR=/tmp
cd /root/.ampdata/instances/Minecraft01
./AMP_Linux_aarch64 +Core.AMP.InstanceName Minecraft01 +Core.AMP.ModuleName Minecraft -configonly 2>&1
echo 'Return code:' \$?
"
