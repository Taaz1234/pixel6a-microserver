#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MC_DIR="/root/.ampdata/instances/Minecraft01/Minecraft"

cd $MC_DIR

# 1. Cambiar puerto a 25565 (el puerto estándar de Minecraft) y desactivar online-mode
sed -i 's/server-port=.*/server-port=25565/' server.properties
sed -i 's/online-mode=.*/online-mode=false/' server.properties
sed -i 's/server-ip=.*/server-ip=0.0.0.0/' server.properties

echo "[+] Configuración actualizada: Puerto 25565, Online-mode: false"

# 2. Reiniciar Java
pkill -9 -f java 2>/dev/null || true
sleep 2

nohup java -Xms1500M -Xmx2500M -XX:+UseG1GC -jar minecraft_server.jar nogui > $MC_DIR/server.log 2>&1 &
echo "[+] Servidor Purpur 1.21.4 MMORPG iniciado en el puerto estándar 25565!"
