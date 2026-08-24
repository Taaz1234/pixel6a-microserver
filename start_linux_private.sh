#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Montando /dev privado en rootfs..."
mount -o bind,private /dev $ROOTFS/dev 2>/dev/null || true
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true
chmod 666 $ROOTFS/dev/ptmx 2>/dev/null || true

chroot $ROOTFS /bin/bash /root/run_amp_instance.sh
sleep 5
echo "=== SERVICIOS ACTIVOS ==="
netstat -tuln | grep -E "8080|8085|8090|8095|8096|25566|3000"
