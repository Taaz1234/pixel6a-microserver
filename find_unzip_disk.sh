#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "=== Outer inspection ==="
ls -la $ROOTFS/usr/bin/unzip 2>/dev/null || echo "No /usr/bin/unzip"
ls -la $ROOTFS/bin/unzip 2>/dev/null || echo "No /bin/unzip"
find $ROOTFS/ -name "unzip" 2>/dev/null
