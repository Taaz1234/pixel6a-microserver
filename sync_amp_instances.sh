#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
mkdir -p /root/.ampdata/instances /home/amp/.ampdata/instances
cp -r /root/.ampdata/* /home/amp/.ampdata/ 2>/dev/null || true
chown -R amp:amp /home/amp/.ampdata 2>/dev/null || true

echo '=== INSTANCIAS COMO ROOT ==='
ampinstmgr --ShowInstancesList

echo '=== INSTANCIAS COMO AMP ==='
su - amp -c 'ampinstmgr --ShowInstancesList'
"
