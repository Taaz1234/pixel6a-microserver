# Deploy permanent microserver directory /data/pixelserver

Write-Host "[1/6] Creando directorio permanente /data/pixelserver..."
.\platform-tools\adb.exe shell "su -c 'mkdir -p /data/pixelserver /data/pixelserver/adguard /data/pixelserver/filebrowser /data/pixelserver/cinema_web /data/pixelserver/dashboard /sdcard/Media/Vigilancia'"

Write-Host "[2/6] Subiendo AdGuard Home..."
.\platform-tools\adb.exe push AdGuardHome\AdGuardHome /data/local/tmp/AdGuardHome
.\platform-tools\adb.exe push AdGuardHome_live.yaml /data/local/tmp/AdGuardHome.yaml
.\platform-tools\adb.exe shell "su -c 'cp /data/local/tmp/AdGuardHome /data/pixelserver/adguard/AdGuardHome; cp /data/local/tmp/AdGuardHome.yaml /data/pixelserver/adguard/AdGuardHome.yaml; chmod +x /data/pixelserver/adguard/AdGuardHome'"

Write-Host "[3/6] Subiendo FileBrowser..."
.\platform-tools\adb.exe push filebrowser_bin\filebrowser /data/local/tmp/filebrowser_bin
.\platform-tools\adb.exe shell "su -c 'cp /data/local/tmp/filebrowser_bin /data/pixelserver/filebrowser/filebrowser; chmod +x /data/pixelserver/filebrowser/filebrowser'"

Write-Host "[4/6] Subiendo Dashboard y Cinema..."
.\platform-tools\adb.exe push dashboard /data/local/tmp/dashboard
.\platform-tools\adb.exe push cinema /data/local/tmp/cinema_web
.\platform-tools\adb.exe shell "su -c 'cp -r /data/local/tmp/dashboard/* /data/pixelserver/dashboard/ 2>/dev/null || true; cp -r /data/local/tmp/cinema_web/* /data/pixelserver/cinema_web/ 2>/dev/null || true'"

Write-Host "[5/6] Subiendo scripts maestros de arranque..."
.\platform-tools\adb.exe push start_amp_clean.sh /data/local/tmp/start_amp_clean.sh
.\platform-tools\adb.exe shell "su -c 'cp /data/local/tmp/start_amp_clean.sh /data/pixelserver/start_amp_clean.sh; chmod 755 /data/pixelserver/start_amp_clean.sh'"

Write-Host "[6/6] Listo!"
