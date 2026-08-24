#!/system/bin/sh
# Pixel 6a Microserver Master Boot Script
# Inicializa todos los microservicios de forma robusta y permanente

sleep 5

# Optimizar rendimiento y evitar suspensión de CPU / Red
dumpsys deviceidle disable deep 2>/dev/null || true
dumpsys deviceidle disable light 2>/dev/null || true
cmd wifi set-wifi-enabled enabled 2>/dev/null || true

BASE_DIR="/data/pixelserver"

# 1. Iniciar AdGuard Home en puerto 3000 y DNS 53
if ! pgrep -x "AdGuardHome" > /dev/null; then
    echo "[+] Iniciando AdGuard Home..."
    nohup $BASE_DIR/adguard/AdGuardHome -c $BASE_DIR/adguard/AdGuardHome.yaml -w $BASE_DIR/adguard > $BASE_DIR/adguard.log 2>&1 &
fi

# 2. Iniciar PixelPulse Dashboard en puerto 8080
if ! pgrep -f "dashboard_server.py" > /dev/null; then
    echo "[+] Iniciando Dashboard en 8080..."
    export LD_LIBRARY_PATH=/data/user/0/com.termux/files/usr/lib:$LD_LIBRARY_PATH
    export PATH=/data/user/0/com.termux/files/usr/bin:$PATH
    nohup /data/user/0/com.termux/files/usr/bin/python3 $BASE_DIR/dashboard/dashboard_server.py > $BASE_DIR/dashboard.log 2>&1 &
fi

# 3. Iniciar FileBrowser en puerto 8090
if ! pgrep -x "filebrowser" > /dev/null; then
    echo "[+] Iniciando FileBrowser en 8090..."
    nohup $BASE_DIR/filebrowser/filebrowser -r /sdcard/Media -a 0.0.0.0 -p 8090 -d $BASE_DIR/filebrowser/filebrowser.db > $BASE_DIR/filebrowser.log 2>&1 &
fi

# 4. Iniciar PixelCinema en puerto 8095 (Series + Películas)
if ! pgrep -f "cinema_server.py" > /dev/null; then
    echo "[+] Iniciando PixelCinema en 8095..."
    nohup /data/pixelserver/start_cinema.sh > /data/pixelserver/cinema.log 2>&1 &
fi

# 5. Iniciar Servidores Linux (CubeCoders AMP + Minecraft + Jellyfin + Playit)
if [ -f $BASE_DIR/start_linux_private.sh ]; then
    sh $BASE_DIR/start_linux_private.sh >/dev/null 2>&1 &
fi

# 6. Iniciar OpenSSH en puerto 8022
if ! pgrep -x "sshd" > /dev/null; then
    echo "[+] Iniciando OpenSSH en 8022..."
    export PATH=/data/user/0/com.termux/files/usr/bin:$PATH
    /data/user/0/com.termux/files/usr/bin/sshd -p 8022 2>/dev/null || true
fi

echo "[OK] Todos los servicios del microservidor iniciados correctamente."
