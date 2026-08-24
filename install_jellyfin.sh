#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Instalando Jellyfin oficial en Ubuntu chroot..."

# Dummy systemctl si no existe para que los scripts post-install de Debian no fallen
if [ ! -f $ROOTFS/usr/bin/systemctl ]; then
    echo '#!/bin/sh' > $ROOTFS/usr/bin/systemctl
    echo 'exit 0' >> $ROOTFS/usr/bin/systemctl
    chmod 755 $ROOTFS/usr/bin/systemctl
fi

chroot $ROOTFS /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

apt-get update
apt-get install -y --no-install-recommends jellyfin

echo '--- Comprobando binario de Jellyfin ---'
which jellyfin
"
