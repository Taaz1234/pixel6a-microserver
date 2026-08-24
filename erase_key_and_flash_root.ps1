$adb = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\platform-tools\adb.exe"
$fastboot = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\platform-tools\fastboot.exe"
$patchedImg = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\magisk_patched.img"

Write-Host "[1/4] Reiniciando en modo Fastboot..." -ForegroundColor Cyan
& $adb reboot bootloader
Start-Sleep -Seconds 6

Write-Host "[2/4] Borrando clave AVB custom (desactivando verificacion estricta)..." -ForegroundColor Cyan
& $fastboot erase avb_custom_key

Write-Host "[3/4] Flasheando kernel parcheado con Magisk..." -ForegroundColor Cyan
& $fastboot flash boot $patchedImg

Write-Host "[4/4] Reiniciando Pixel 6a..." -ForegroundColor Green
& $fastboot reboot
