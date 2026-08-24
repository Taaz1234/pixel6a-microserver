#!/bin/sh
echo "=== PUERTOS ACTIVOS ==="
netstat -tuln 2>/dev/null

echo "=== PROCESOS ACTIVOS ==="
ps -ef | grep -E "AdGuard|filebrowser|python|aria2|AMP|sshd|pihole|lighttpd|dnsmasq|FTL|proot" | grep -v grep

echo "=== SERVICIOS EN /data/local/tmp ==="
ls -la /data/local/tmp

echo "=== SERVICIOS EN /sdcard ==="
ls -la /sdcard/*.py /sdcard/*.sh 2>/dev/null || true
