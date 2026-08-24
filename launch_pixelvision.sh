#!/system/bin/sh
export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
export PATH=/data/data/com.termux/files/usr/bin:$PATH

pkill -9 -f pixelvision_server.py 2>/dev/null || true
sleep 1

/data/data/com.termux/files/usr/bin/python3 /data/local/tmp/pixelvision_server.py > /data/local/tmp/pixelvision.log 2>&1 &

sleep 2
netstat -tuln | grep 8088 || echo "Waiting on port 8088..."
cat /data/local/tmp/pixelvision.log || true
