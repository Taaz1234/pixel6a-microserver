#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
APP_DIR="/root/pixelsteam"

mkdir -p $APP_DIR

echo "[+] Verificando proceso de PixelSteam Deals..."
pkill -f "python3.*pixelsteam/server.py" 2>/dev/null || true
pkill -f "python3.*server.py" 2>/dev/null || true
sleep 1

echo "[+] Arrancando PixelSteam Deals en http://0.0.0.0:8098 ..."
nohup python3 $APP_DIR/server.py > $APP_DIR/steam.log 2>&1 &
echo "[+] PixelSteam Deals iniciado correctamente en segundo plano!"
