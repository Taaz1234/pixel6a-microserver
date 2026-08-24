#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

chroot $ROOTFS /bin/bash -c "
dpkg -L unzip
ls -la /usr/bin/unzip 2>/dev/null || true
ls -la /bin/unzip 2>/dev/null || true
"
