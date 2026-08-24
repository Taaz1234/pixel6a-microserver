$tools = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\platform-tools"
$factory = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\bluejay-factory\image-bluejay-install-2026081300"
$patched = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\magisk_patched.img"

Write-Host "[1/4] Instalando Magisk APK..." -ForegroundColor Cyan
& "$tools\adb.exe" install -r "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\Magisk.apk"

Write-Host "[2/4] Reiniciando Pixel 6a a modo Fastboot..." -ForegroundColor Cyan
& "$tools\adb.exe" reboot bootloader
Start-Sleep -Seconds 6

Write-Host "[3/4] Flasheando vbmeta con deshabilitacion de verificacion de integridad..." -ForegroundColor Cyan
& "$tools\fastboot.exe" --disable-verity --disable-verification flash vbmeta "$factory\vbmeta.img"
& "$tools\fastboot.exe" --disable-verity --disable-verification flash vbmeta_system "$factory\vbmeta_system.img"
& "$tools\fastboot.exe" --disable-verity --disable-verification flash vbmeta_vendor "$factory\vbmeta_vendor.img"

Write-Host "[4/4] Flasheando kernel rooteado (magisk_patched.img)..." -ForegroundColor Cyan
& "$tools\fastboot.exe" flash boot "$patched"

Write-Host "[+] Reiniciando al sistema..." -ForegroundColor Green
& "$tools\fastboot.exe" reboot
