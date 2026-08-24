#!/system/bin/sh
ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

echo "[1/3] Configurando FileBrowser (8090)..."
pkill -9 -f filebrowser 2>/dev/null || true
/data/pixelserver/filebrowser/filebrowser config set --minimumPasswordLength 4 -d /data/pixelserver/filebrowser/filebrowser.db
/data/pixelserver/filebrowser/filebrowser users update admin -p Paco3421 -d /data/pixelserver/filebrowser/filebrowser.db
nohup /data/pixelserver/filebrowser/filebrowser -r /sdcard/Media -a 0.0.0.0 -p 8090 -d /data/pixelserver/filebrowser/filebrowser.db > /data/pixelserver/filebrowser.log 2>&1 &
echo "[OK] FileBrowser: admin / Paco3421 configurado."

echo "[2/3] Configurando CubeCoders AMP (8085)..."
chroot $ROOTFS su -l amp -c "ampinstmgr --ResetLogin ADS01 admin Paco3421 2>/dev/null || ampinstmgr --ResetLogin ADS admin Paco3421 2>/dev/null"
chroot $ROOTFS su -l root -c "ampinstmgr --ResetLogin ADS01 admin Paco3421 2>/dev/null || true"
echo "[OK] AMP: admin / Paco3421 configurado."

echo "[3/3] Configurando AdGuard Home (3000)..."
pkill -9 -f AdGuardHome 2>/dev/null || true
nohup /data/pixelserver/adguard/AdGuardHome -c /data/pixelserver/adguard/AdGuardHome.yaml -w /data/pixelserver/adguard > /data/pixelserver/adguard.log 2>&1 &
echo "[OK] AdGuard Home: admin / Paco3421 configurado."

sleep 2
echo "=== SERVICIOS ACTIVOS ==="
netstat -tuln | grep -E "8080|8085|8090|8095|8096|25566|3000"
