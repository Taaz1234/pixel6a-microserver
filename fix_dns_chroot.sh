#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf
echo "nameserver 127.0.0.1" >> $ROOTFS/etc/resolv.conf
chmod 644 $ROOTFS/etc/resolv.conf

# Configurar nsswitch
cat << 'EOF' > $ROOTFS/etc/nsswitch.conf
passwd:         files
group:          files
shadow:         files
gshadow:        files
hosts:          files dns
networks:       files
protocols:      db files
services:       db files
ethers:         db files
rpc:            db files
netgroup:       nis
EOF

chroot $ROOTFS /bin/su amp -c "curl -I https://1.1.1.1 -k; getent hosts cdn-downloads.c7rs.com || true; curl -I https://cdn-downloads.c7rs.com 2>&1"
