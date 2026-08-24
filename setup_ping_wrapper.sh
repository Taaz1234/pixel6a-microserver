#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Creando /bin/ping y /usr/bin/ping en chroot..."

cat << 'EOF' > $ROOTFS/bin/ping
#!/bin/sh
if [ -x /system/bin/ping ]; then
    /system/bin/ping "$@" 2>/dev/null || exit 0
else
    exit 0
fi
EOF

chmod 755 $ROOTFS/bin/ping
cp $ROOTFS/bin/ping $ROOTFS/usr/bin/ping
cp $ROOTFS/bin/ping $ROOTFS/usr/local/bin/ping

echo "[+] Probando ping dentro del chroot..."
chroot $ROOTFS /bin/bash -c "which ping; ping 1.1.1.1 -c 1; echo 'Ping exit code:' \$?"
