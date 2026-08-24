#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Limpiando lista de fuentes..."
rm -f $ROOTFS/etc/apt/sources.list.d/playit-cloud.list

echo "[+] Descargando binario oficial aarch64 de Playit.gg..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
curl -SsL -o /usr/local/bin/playit https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-aarch64
chmod 755 /usr/local/bin/playit

echo '--- Version de Playit instalada ---'
playit --version
"
