#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "=== VERIFICANDO JAVA EN UBUNTU CONTAINER ==="
chroot $ROOTFS /bin/bash -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; which java; java -version; which javac"
