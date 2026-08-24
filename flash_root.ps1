$adb = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\platform-tools\adb.exe"
$fastboot = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\platform-tools\fastboot.exe"
$patchedImg = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\magisk_patched.img"

Write-Host "[1/4] Extrayendo boot parcheado desde el dispositivo..." -ForegroundColor Cyan
& $adb pull /sdcard/Download/magisk_patched-27000_fc9hO.img $patchedImg

Write-Host "[2/4] Reiniciando en modo Fastboot..." -ForegroundColor Cyan
& $adb reboot bootloader

Write-Host "Esperando 6 segundos a que fastboot este listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 6

Write-Host "[3/4] Flasheando boot parcheado con Magisk..." -ForegroundColor Cyan
& $fastboot flash boot $patchedImg

Write-Host "[4/4] Reiniciando Pixel 6a con Root activo..." -ForegroundColor Green
& $fastboot reboot

Write-Host "[OK] Proceso de Root completado con exito." -ForegroundColor Green
