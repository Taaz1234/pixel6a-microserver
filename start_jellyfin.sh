#!/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Configurando directorios y permisos para Jellyfin..."
mkdir -p $ROOTFS/var/lib/jellyfin $ROOTFS/var/cache/jellyfin $ROOTFS/etc/jellyfin $ROOTFS/var/log/jellyfin $ROOTFS/media/Media

# Montar subsistemas del kernel y almacenamiento de medios
mount -o bind /dev $ROOTFS/dev 2>/dev/null || true
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true

echo "[+] Creando script de arranque interno de Jellyfin..."
cat << 'EOF' > $ROOTFS/usr/local/bin/run_jellyfin.sh
#!/bin/bash
export HOME=/root
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jellyfin-ffmpeg

mkdir -p /var/lib/jellyfin /var/cache/jellyfin /etc/jellyfin /var/log/jellyfin

exec /usr/bin/jellyfin \
    --datadir /var/lib/jellyfin \
    --cachedir /var/cache/jellyfin \
    --configdir /etc/jellyfin \
    --logdir /var/log/jellyfin \
    --webdir /usr/share/jellyfin/web \
    --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg
EOF

chmod 755 $ROOTFS/usr/local/bin/run_jellyfin.sh

echo "[+] Iniciando Jellyfin en segundo plano..."
chroot $ROOTFS /bin/bash -c "
nohup /usr/local/bin/run_jellyfin.sh > /var/log/jellyfin/stdout.log 2>&1 &
"

sleep 4

echo "=== ESTADO DE JELLYFIN Y PUERTOS ==="
chroot $ROOTFS /bin/bash -c "
ps aux | grep -i jellyfin | grep -v grep
"
netstat -tuln | grep 8096 || true
