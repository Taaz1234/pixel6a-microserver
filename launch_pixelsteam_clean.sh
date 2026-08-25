#!/system/bin/sh
APP_DIR="/data/pixelserver/pixelsteam"

mkdir -p $APP_DIR/static
cp /data/local/tmp/server.py $APP_DIR/server.py
cp /data/local/tmp/index.html $APP_DIR/static/index.html
cp /data/local/tmp/style.css $APP_DIR/static/style.css
cp /data/local/tmp/app.js $APP_DIR/static/app.js
chmod -R 755 $APP_DIR

pkill -f "pixelsteam/server.py" 2>/dev/null || true
pkill -f "python3.*server.py" 2>/dev/null || true
sleep 1

export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
nohup /data/data/com.termux/files/usr/bin/python3 $APP_DIR/server.py > /data/pixelserver/pixelsteam.log 2>&1 &
sleep 2

echo "=== ESTADO DE PIXELSTEAM EN PUERTO 8098 ==="
netstat -tuln | grep 8098
