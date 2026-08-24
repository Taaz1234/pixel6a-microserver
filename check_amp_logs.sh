#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ls -la /root/.ampdata/instances/ADS01/ 2>/dev/null || true
ls -la /root/.ampdata/instances/ADS01/AMP_Logs/ 2>/dev/null || true
cat /root/.ampdata/instances/ADS01/AMP_Logs/*.log 2>/dev/null || true
"
