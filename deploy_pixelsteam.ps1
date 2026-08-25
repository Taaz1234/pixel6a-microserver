Write-Host "=== DESPLEGANDO PIXELSTEAM DEALS EN PIXEL 6A ===" -ForegroundColor Cyan

$adb = ".\platform-tools\adb.exe"

# 1. Crear directorio en el Pixel
& $adb shell "su -c 'mkdir -p /data/pixelserver/pixelsteam/static'"

# 2. Subir archivos
Write-Host "[+] Subiendo servidor y frontend..." -ForegroundColor Green
& $adb push pixelsteam/server.py /data/local/tmp/server.py
& $adb push pixelsteam/static/index.html /data/local/tmp/index.html
& $adb push pixelsteam/static/style.css /data/local/tmp/style.css
& $adb push pixelsteam/static/app.js /data/local/tmp/app.js

& $adb shell "su -c '
cp /data/local/tmp/server.py /data/pixelserver/pixelsteam/server.py
cp /data/local/tmp/index.html /data/pixelserver/pixelsteam/static/index.html
cp /data/local/tmp/style.css /data/pixelserver/pixelsteam/static/style.css
cp /data/local/tmp/app.js /data/pixelserver/pixelsteam/static/app.js
chmod -R 755 /data/pixelserver/pixelsteam
'"

# 3. Reiniciar servicio
Write-Host "[+] Iniciando PixelSteam Deals en http://192.168.1.135:8098 ..." -ForegroundColor Green
& $adb shell "su -c '
pkill -f \"pixelsteam/server.py\" 2>/dev/null || true
export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH
nohup /data/data/com.termux/files/usr/bin/python3 /data/pixelserver/pixelsteam/server.py > /data/pixelserver/pixelsteam.log 2>&1 &
'"

Start-Sleep -Seconds 2
& $adb shell "su -c 'netstat -tuln | grep 8098'"
Write-Host "[+] ¡Despliegue completado! Abre en tu navegador: http://192.168.1.135:8098" -ForegroundColor Cyan
