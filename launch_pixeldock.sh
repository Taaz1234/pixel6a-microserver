#!/system/bin/sh
pkill -f "pixeldock/server.py" 2>/dev/null || true
sleep 1

export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
cd /data/pixelserver/pixeldock
nohup /data/data/com.termux/files/usr/bin/python3 server.py > /data/pixelserver/pixeldock.log 2>&1 &
sleep 2

echo "=== ESTADO DE PIXELDOCK EN PUERTO 8088 ==="
netstat -tulpn | grep 8088 || true
