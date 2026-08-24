#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Preparando nodos /dev para C#/.NET Cryptography..."
mkdir -p $ROOTFS/dev/pts
touch $ROOTFS/dev/urandom $ROOTFS/dev/random $ROOTFS/dev/null $ROOTFS/dev/zero

mount -o bind /dev/urandom $ROOTFS/dev/urandom 2>/dev/null || true
mount -o bind /dev/random $ROOTFS/dev/random 2>/dev/null || true
mount -o bind /dev/null $ROOTFS/dev/null 2>/dev/null || true
mount -o bind /dev/zero $ROOTFS/dev/zero 2>/dev/null || true
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
chmod 666 $ROOTFS/dev/ptmx 2>/dev/null || true

echo "nameserver 1.1.1.1" > $ROOTFS/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $ROOTFS/etc/resolv.conf

# Matar instancias previas
pkill -9 -f AMP_Linux_aarch64 2>/dev/null || true
pkill -9 -f jellyfin 2>/dev/null || true

echo "[+] Arrancando CubeCoders AMP..."
chroot $ROOTFS /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp
cd /root/.ampdata/instances/ADS01
./AMP_Linux_aarch64 +Core.Webserver.Port 8085 +Core.Webserver.IPBinding 0.0.0.0 > /root/.ampdata/instances/ADS01/amp_web.log 2>&1 &
sleep 2
ampinstmgr --StartBoot 2>/dev/null || true
"

echo "[+] Arrancando Jellyfin..."
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true
chroot $ROOTFS /bin/bash -c "
/usr/local/bin/run_jellyfin.sh > /var/log/jellyfin/stdout.log 2>&1 &
"

sleep 4
echo "=== SERVICIOS LINUX ACTIVOS ==="
netstat -tuln | grep -E "8085|8096|25566"
