#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Montando /dev específicos..."
mount -o bind /dev/null $ROOTFS/dev/null 2>/dev/null || true
mount -o bind /dev/zero $ROOTFS/dev/zero 2>/dev/null || true
mount -o bind /dev/urandom $ROOTFS/dev/urandom 2>/dev/null || true
mount -o bind /dev/random $ROOTFS/dev/random 2>/dev/null || true
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true

chroot $ROOTFS /bin/bash /root/run_amp_instance.sh
sleep 4
netstat -tuln | grep -E "8085|8096|25566"
