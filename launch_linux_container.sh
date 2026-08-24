#!/system/bin/sh
# Launcher de Ubuntu y Servicios Linux en un Namespace Aislado (Protege 100% las apps de Android)

ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

exec /system/bin/unshare -m /system/bin/sh -c "
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true

# Iniciar CubeCoders AMP
if ! pgrep -f 'AMP_Linux_aarch64' > /dev/null; then
    echo '[+] Iniciando CubeCoders AMP en 8085...'
    sh /data/local/tmp/start_amp_clean.sh >/dev/null 2>&1 &
fi

# Iniciar Jellyfin
if ! pgrep -x 'jellyfin' > /dev/null; then
    echo '[+] Iniciando Jellyfin en 8096...'
    chroot $ROOTFS /bin/bash -c '/usr/local/bin/run_jellyfin.sh > /var/log/jellyfin/stdout.log 2>&1 &'
fi

# Iniciar Playit.gg
if ! pgrep -x 'playit' > /dev/null; then
    echo '[+] Iniciando Playit.gg...'
    chroot $ROOTFS /bin/bash -c '/usr/local/bin/playit > /var/log/playit.log 2>&1 &'
fi

wait
"
