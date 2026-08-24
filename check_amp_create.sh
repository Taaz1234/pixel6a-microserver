#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

chroot $ROOTFS /bin/bash -c "export PATH=/usr/local/bin:/opt/cubecoders/amp:$PATH; ampinstmgr CreateInstance --help"
