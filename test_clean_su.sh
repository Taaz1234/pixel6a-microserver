#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

cat << 'EOF' > $ROOTFS/usr/bin/su
#!/bin/sh
cmd=""
last=""
for arg in "$@"; do
    if [ "$last" = "-c" ] || [ "$last" = "--command" ]; then
        cmd="$arg"
        break
    fi
    last="$arg"
done

if [ -n "$cmd" ]; then
    export HOME=/root
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TMP=/tmp
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
    exec /bin/sh -c "$cmd"
fi
exit 0
EOF

chmod 755 $ROOTFS/usr/bin/su
cp $ROOTFS/usr/bin/su $ROOTFS/bin/su 2>/dev/null || true
cp $ROOTFS/usr/bin/su $ROOTFS/usr/local/bin/su 2>/dev/null || true

echo "[+] Probando su wrapper en chroot..."
chroot $ROOTFS /bin/bash -c "
su -l root -c 'echo SU_TEST_SUCCESSFUL'
"

echo "[+] Limpiando instancia previa Minecraft01..."
rm -rf $ROOTFS/root/.ampdata/instances/Minecraft01

echo "[+] Ejecutando creacion de instancia Minecraft..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp
cd /root

ampinstmgr --CreateInstance Minecraft Minecraft01 0.0.0.0 25565 '83358a72-e26c-46c2-b8d6-377f71bef408' admin Paco3421
"
