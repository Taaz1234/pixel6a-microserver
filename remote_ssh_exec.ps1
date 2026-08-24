Write-Host "=== INTENTANDO CONEXION SSH A 192.168.1.135:8022 ===" -ForegroundColor Cyan

$remoteScript = 'mkdir -p /data/pixelserver/cinema_web; cp /sdcard/Media/cinema_server.py /data/pixelserver/cinema_web/; cp /sdcard/Media/index.html /data/pixelserver/cinema_web/; pkill -f cinema_server.py; export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH; nohup /data/data/com.termux/files/usr/bin/python3 /data/pixelserver/cinema_web/cinema_server.py > /data/pixelserver/cinema.log 2>&1 &'

# Intentar ejecutar con ssh
$proc = Start-Process -FilePath "ssh" -ArgumentList "-o StrictHostKeyChecking=no -o ConnectTimeout=5 -p 8022 192.168.1.135 `"$remoteScript`"" -NoNewWindow -PassThru -Wait
Write-Host "Exit code:" $proc.ExitCode
