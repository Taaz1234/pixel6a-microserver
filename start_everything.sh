#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "=== ESTADO DE SERVICIOS DEL MICROSERVIDOR PIXEL 6A ==="

# 1. AdGuard Home (3000 / 53)
if ! pgrep -x "AdGuardHome" > /dev/null; then
    echo "[+] Iniciando AdGuard Home en 3000..."
    nohup /data/pixelserver/adguard/AdGuardHome -c /data/pixelserver/adguard/AdGuardHome.yaml -w /data/pixelserver/adguard > /data/pixelserver/adguard.log 2>&1 &
fi

# 2. PixelPulse Dashboard (8080)
if ! pgrep -f "dashboard_server.py" > /dev/null; then
    echo "[+] Iniciando Dashboard en 8080..."
    export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
    nohup /data/data/com.termux/files/usr/bin/python3 /data/pixelserver/dashboard/dashboard_server.py > /data/pixelserver/dashboard.log 2>&1 &
fi

# 3. FileBrowser (8090)
if ! pgrep -x "filebrowser" > /dev/null; then
    echo "[+] Iniciando FileBrowser en 8090..."
    nohup /data/pixelserver/filebrowser/filebrowser -r /sdcard/Media -a 0.0.0.0 -p 8090 -d /data/pixelserver/filebrowser/filebrowser.db > /data/pixelserver/filebrowser.log 2>&1 &
fi

# 4. PixelCinema Pro v2 (8095)
if ! pgrep -f "cinema_server.py" > /dev/null; then
    echo "[+] Iniciando PixelCinema en 8095..."
    export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
    nohup /data/data/com.termux/files/usr/bin/python3 /data/pixelserver/cinema_web/cinema_server.py > /data/pixelserver/cinema.log 2>&1 &
fi

# 5. PixelSteam Deals SteamDB Pro (8098)
if ! pgrep -f "pixelsteam/server.py" > /dev/null; then
    echo "[+] Iniciando PixelSteam Deals en 8098..."
    export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
    nohup /data/data/com.termux/files/usr/bin/python3 /data/pixelserver/pixelsteam/server.py > /data/pixelserver/pixelsteam.log 2>&1 &
fi

# 6. OpenSSH (8022)
if ! pgrep -x "sshd" > /dev/null; then
    echo "[+] Iniciando OpenSSH en 8022..."
    export PATH=/data/data/com.termux/files/usr/bin:$PATH
    /data/data/com.termux/files/usr/bin/sshd -p 8022 2>/dev/null || true
fi

# 7. Ubuntu chroot (devpts, proc, sys)
mkdir -p $ROOTFS/dev/pts
mount -t devpts devpts $ROOTFS/dev/pts 2>/dev/null || true
mount -t proc proc $ROOTFS/proc 2>/dev/null || true
mount -t sysfs sys $ROOTFS/sys 2>/dev/null || true
mount -o bind /sdcard/Media $ROOTFS/media/Media 2>/dev/null || true
chmod 666 $ROOTFS/dev/ptmx 2>/dev/null || true

# 8. CubeCoders AMP (8085)
if ! pgrep -f "AMP_Linux_aarch64" > /dev/null; then
    echo "[+] Iniciando CubeCoders AMP en 8085..."
    chroot $ROOTFS /bin/bash -c "
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
    export HOME=/root
    cd /opt/cubecoders/amp
    ./AMP_Linux_aarch64 +Core.Webserver.Port 8085 +Core.Webserver.IPBinding 0.0.0.0 > /root/amp.log 2>&1 &
    sleep 2
    ampinstmgr --StartBoot 2>/dev/null || true
    "
fi

# 9. Jellyfin (8096)
if ! pgrep -x "jellyfin" > /dev/null; then
    echo "[+] Iniciando Jellyfin en 8096..."
    chroot $ROOTFS /bin/bash -c "
    nohup /usr/local/bin/run_jellyfin.sh > /var/log/jellyfin/stdout.log 2>&1 &
    "
fi

# 10. Minecraft Purpur 1.21.4 (25565)
if ! pgrep -f "minecraft_server.jar" > /dev/null; then
    echo "[+] Iniciando Minecraft Purpur en 25565..."
    chroot $ROOTFS /bin/bash -c "
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    cd /root/.ampdata/instances/Minecraft01/Minecraft
    nohup java -Xms1500M -Xmx2500M -XX:+UseG1GC -jar minecraft_server.jar nogui > /root/.ampdata/instances/Minecraft01/Minecraft/server.log 2>&1 &
    "
fi

sleep 3
echo "=== PUERTOS ACTIVOS ==="
netstat -tuln | grep -E "8080|8085|8090|8095|8096|8098|25565|3000|8022"
