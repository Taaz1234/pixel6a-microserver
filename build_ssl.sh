#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true

chroot $ROOTFS /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
apt-get update
apt-get install -y openssl
openssl req -x509 -newkey rsa:2048 -keyout /data/local/tmp/key.pem -out /data/local/tmp/cert.pem -days 3650 -nodes -subj '/CN=192.168.1.135'
"

ls -la /data/local/tmp/cert.pem /data/local/tmp/key.pem
