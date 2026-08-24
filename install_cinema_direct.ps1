Write-Host "=== INSTALANDO PIXELCINEMA PRO V2.0 DIRECTO AL SISTEMA ===" -ForegroundColor Cyan

# 1. Push directo a /data/local/tmp
.\platform-tools\adb.exe push cinema\cinema_server.py /data/local/tmp/cinema_server.py
.\platform-tools\adb.exe push cinema\index.html /data/local/tmp/index.html

# 2. Instalar en /data/pixelserver/cinema_web
.\platform-tools\adb.exe shell "su -c 'mkdir -p /data/pixelserver/cinema_web /sdcard/Media/Peliculas /sdcard/Media/Series; cp /data/local/tmp/cinema_server.py /data/pixelserver/cinema_web/cinema_server.py; cp /data/local/tmp/index.html /data/pixelserver/cinema_web/index.html; rm -f /data/local/tmp/cinema_server.py /data/local/tmp/index.html; chmod -R 755 /data/pixelserver/cinema_web'"

# 3. Matar proceso previo y arrancar cinema_server.py
.\platform-tools\adb.exe shell "su -c 'pkill -f cinema_server.py || true; export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:\$LD_LIBRARY_PATH; nohup /data/data/com.termux/files/usr/bin/python3 /data/pixelserver/cinema_web/cinema_server.py > /data/pixelserver/cinema.log 2>&1 &'"

Start-Sleep -Seconds 2

# 4. Verificar log y estado
$log = .\platform-tools\adb.exe shell "su -c 'cat /data/pixelserver/cinema.log'"
Write-Host "LOG de PixelCinema:" $log

$proc = .\platform-tools\adb.exe shell "su -c 'pgrep -fl cinema_server.py'"
Write-Host "Proceso activo:" $proc
