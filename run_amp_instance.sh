#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
export HOME=/root
export TMPDIR=/tmp

echo "[+] Levantando ADS01..."
cd /root/.ampdata/instances/ADS01
nohup ./AMP_Linux_aarch64 +Core.Webserver.Port 8085 +Core.Webserver.IPBinding 0.0.0.0 > /root/.ampdata/instances/ADS01/amp.log 2>&1 &
sleep 2

echo "[+] Levantando Minecraft01..."
cd /root/.ampdata/instances/Minecraft01
nohup ./AMP_Linux_aarch64 > /root/.ampdata/instances/Minecraft01/mc.log 2>&1 &
sleep 2

echo "[+] Levantando Jellyfin..."
nohup /usr/local/bin/run_jellyfin.sh > /var/log/jellyfin/stdout.log 2>&1 &
sleep 2

echo "[+] Levantando Playit..."
nohup /usr/local/bin/playit > /var/log/playit.log 2>&1 &
sleep 1

echo "Done!"
