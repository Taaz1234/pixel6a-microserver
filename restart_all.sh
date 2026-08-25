#!/system/bin/sh
pkill -9 -f "server.py" 2>/dev/null || true
sleep 1
sh /data/local/tmp/start_subs.sh
sh /data/local/tmp/launch_pixeldock.sh
