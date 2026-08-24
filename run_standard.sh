#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

cp /data/local/tmp/set_standard_port.sh $ROOTFS/tmp/set_standard_port.sh
chmod 755 $ROOTFS/tmp/set_standard_port.sh

chroot $ROOTFS /bin/bash /tmp/set_standard_port.sh
