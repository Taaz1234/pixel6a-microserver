$tools = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\platform-tools"
$dir = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver"

Write-Host "[1/5] Aplicando persistencia energética y de red 24/7..." -ForegroundColor Cyan
& "$tools\adb.exe" shell "dumpsys deviceidle disable"
& "$tools\adb.exe" shell "settings put global wifi_sleep_policy 2"
& "$tools\adb.exe" shell "settings put global stay_on_while_plugged_in 3"
& "$tools\adb.exe" shell "settings put global wifi_stay_on 1"
& "$tools\adb.exe" shell "settings put global low_power 0"

Write-Host "[2/5] Instalando Termux ARM64..." -ForegroundColor Cyan
& "$tools\adb.exe" install -r -g "$dir\Termux-arm64.apk"

Write-Host "[3/5] Otorgando permisos a Termux..." -ForegroundColor Cyan
& "$tools\adb.exe" shell "dumpsys deviceidle whitelist +com.termux"
& "$tools\adb.exe" shell "appops set com.termux RUN_IN_BACKGROUND allow"
& "$tools\adb.exe" shell "pm grant com.termux android.permission.INTERNET" 2>$null
& "$tools\adb.exe" shell "pm grant com.termux android.permission.POST_NOTIFICATIONS" 2>$null

Write-Host "[4/5] Transfiriendo AdGuard Home y configuraciones..." -ForegroundColor Cyan
& "$tools\adb.exe" push "$dir\AdGuardHome\AdGuardHome" /data/local/tmp/AdGuardHome
& "$tools\adb.exe" shell "chmod 755 /data/local/tmp/AdGuardHome"
& "$tools\adb.exe" shell "mkdir -p /data/local/tmp/adguard_work"
& "$tools\adb.exe" push "$dir\AdGuardHome.yaml" /data/local/tmp/adguard_work/AdGuardHome.yaml
& "$tools\adb.exe" push "$dir\autostart.sh" /sdcard/autostart.sh
& "$tools\adb.exe" push "$dir\bootstrap_server.sh" /data/local/tmp/bootstrap_server.sh
& "$tools\adb.exe" shell "chmod 777 /data/local/tmp/bootstrap_server.sh"

Write-Host "[5/5] Iniciando Termux y aprovisionando OpenSSH..." -ForegroundColor Cyan
& "$tools\adb.exe" shell am start -n com.termux/.app.TermuxActivity
Start-Sleep -Seconds 1
& "$tools\adb.exe" shell "input text 'bash /data/local/tmp/bootstrap_server.sh'"
& "$tools\adb.exe" shell "input keyevent 66"

Write-Host "[+] Verificando IP y servicios..." -ForegroundColor Green
& "$tools\adb.exe" shell ip addr show wlan0
