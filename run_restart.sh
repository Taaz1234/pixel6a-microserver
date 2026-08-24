#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

cp /data/local/tmp/restart_clean_mc.sh $ROOTFS/tmp/restart_clean_mc.sh
chmod 755 $ROOTFS/tmp/restart_clean_mc.sh

chroot $ROOTFS /bin/bash /tmp/restart_clean_mc.sh
