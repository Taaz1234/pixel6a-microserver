#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[+] Iniciando FileBrowser en 8090..."
pkill -x filebrowser 2>/dev/null || true
sleep 1
nohup /data/pixelserver/filebrowser/filebrowser -r /sdcard/Media -a 0.0.0.0 -p 8090 -d /data/pixelserver/filebrowser/filebrowser.db > /data/pixelserver/filebrowser.log 2>&1 &

echo "[+] Iniciando AMP en 8085..."
sh /data/pixelserver/start_amp_clean.sh >/dev/null 2>&1 &

echo "[+] Iniciando Jellyfin en 8096..."
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true
chroot $ROOTFS /bin/bash -c "nohup /usr/local/bin/run_jellyfin.sh > /var/log/jellyfin/stdout.log 2>&1 &"

sleep 3
netstat -tuln | grep -E "8080|8085|8090|8095|8096|25566|3000"
