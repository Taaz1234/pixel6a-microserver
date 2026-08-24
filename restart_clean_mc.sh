#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MC_DIR="/root/.ampdata/instances/Minecraft01/Minecraft"

cd $MC_DIR
echo "[+] Matando procesos previos de Java..."
pkill -9 -f java 2>/dev/null || true
sleep 3

echo "[+] Arrancando Purpur 1.21.4 MMORPG..."
nohup java -Xms1500M -Xmx2500M -XX:+UseG1GC -jar minecraft_server.jar nogui > $MC_DIR/server.log 2>&1 &
echo "[+] Servidor iniciado correctamente."
