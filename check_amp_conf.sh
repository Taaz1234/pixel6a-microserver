#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

chroot $ROOTFS /bin/bash -c "
cat /root/.ampdata/instances/ADS01/AMPConfig.conf 2>/dev/null || true
"
