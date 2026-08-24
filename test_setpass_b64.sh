#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Probando -setpass con base64..."

chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export TMPDIR=/tmp
cd /root/.ampdata/instances/ADS01
./AMP_Linux_aarch64 -setpass UGFjbzM0MjE= +Core.Login.Username admin 2>&1
"
