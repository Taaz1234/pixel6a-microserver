#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

# Asegurar directorios
mkdir -p $ROOTFS/root/.ampdata/instances/ADS01
mkdir -p $ROOTFS/usr/bin
which_unzip=$(chroot $ROOTFS which unzip 2>/dev/null || echo "/usr/bin/unzip")
echo "Unzip located at: $which_unzip"

# Link unzip to /usr/bin/unzip if needed
chroot $ROOTFS /bin/bash -c "
ln -sf \$(which unzip) /usr/bin/unzip 2>/dev/null || true
ln -sf \$(which tmux) /usr/bin/tmux 2>/dev/null || true
ln -sf \$(which socat) /usr/bin/socat 2>/dev/null || true
ln -sf \$(which git) /usr/bin/git 2>/dev/null || true
mkdir -p /root/.ampdata/instances/ADS01
"

# Ejecutar QuickStart
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp
cd /root
ampinstmgr QuickStart admin Paco3421 0.0.0.0 8085
"
