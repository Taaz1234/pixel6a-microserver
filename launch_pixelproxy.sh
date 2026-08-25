#!/system/bin/sh
pkill -9 -f "pixelproxy/server.py" 2>/dev/null || true
sleep 1

export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
cd /data/pixelserver/pixelproxy
nohup /data/data/com.termux/files/usr/bin/python3 server.py > /data/pixelserver/pixelproxy.log 2>&1 &
sleep 2

echo "=== ESTADO DE PIXELPROXY EN PUERTO 8082 ==="
netstat -tulpn | grep 8082 || true
