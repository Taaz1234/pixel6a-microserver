#!/system/bin/sh
APP_DIR="/data/pixelserver/pixelsteam"

pkill -f "pixelsteam/server.py" 2>/dev/null || true
sleep 1

export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
cd $APP_DIR
nohup /data/data/com.termux/files/usr/bin/python3 server.py > /data/pixelserver/pixelsteam.log 2>&1 &
sleep 2

echo "=== ESTADO DE PIXELSTEAM EN PUERTO 8098 ==="
netstat -tulpn | grep 8098 || true
