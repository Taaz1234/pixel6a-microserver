Write-Host "=== DESPLEGANDO PIXELCINEMA PRO V2.0 (PELÍCULAS & SERIES) ===" -ForegroundColor Cyan

# 1. Asegurar directorios de destino en /sdcard/Media
.\platform-tools\adb.exe shell "su -c 'mkdir -p /sdcard/Media/Peliculas /sdcard/Media/Series /data/pixelserver/cinema_web'"

# 2. Copiar archivos actualizados
.\platform-tools\adb.exe push cinema\cinema_server.py /sdcard/cinema_server.py
.\platform-tools\adb.exe push cinema\index.html /sdcard/index.html

# 3. Mover a almacenamiento permanente /data/pixelserver/cinema_web
.\platform-tools\adb.exe shell "su -c 'cp /sdcard/cinema_server.py /data/pixelserver/cinema_web/cinema_server.py; cp /sdcard/index.html /data/pixelserver/cinema_web/index.html; rm /sdcard/cinema_server.py /sdcard/index.html; chmod 755 /data/pixelserver/cinema_web/*'"

# 4. Reiniciar el servicio de PixelCinema en puerto 8095
.\platform-tools\adb.exe shell "su -c 'pkill -f cinema_server.py; export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:\$LD_LIBRARY_PATH; nohup /data/data/com.termux/files/usr/bin/python3 /data/pixelserver/cinema_web/cinema_server.py > /data/pixelserver/cinema.log 2>&1 &'"

Start-Sleep -Seconds 2

# 5. Comprobar que responde en el puerto 8095
try {
    $res = Invoke-WebRequest -Uri "http://192.168.1.135:8095" -TimeoutSec 5
    Write-Host "[+] ¡PixelCinema Pro v2.0 Desplegado y Activo en http://192.168.1.135:8095! (Status $($res.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "[-] Error al verificar el puerto 8095: $_" -ForegroundColor Red
}
