<#
.SYNOPSIS
    Fase 2: Asistente para Flasheo de Root (Magisk Boot Patched) en Pixel 6a (Tensor G1).
.DESCRIPTION
    Flashea la imagen boot.img parcheada con Magisk en la partición 'boot' de bluejay.
    Nota Técnica: A diferencia de Pixel 7/8 (que usan init_boot), Pixel 6a (bluejay) usa 'boot'.
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$PatchedBootImgPath = ""
)

$ErrorActionPreference = "Stop"
$WorkDir = "$PSScriptRoot\..\platform-tools"
if (Test-Path "$WorkDir\fastboot.exe") {
    $env:PATH = "$WorkDir;$env:PATH"
    $fastbootPath = "$WorkDir\fastboot.exe"
} else {
    $fastbootPath = "fastboot"
}

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "   PIXEL 6a (bluejay) - INSTALACIÓN DE ROOT / MAGISK   " -ForegroundColor Cyan
Write-Host "=======================================================`n" -ForegroundColor Cyan

if (-not $PatchedBootImgPath) {
    Write-Host @"
INSTRUCCIONES PARA GENERAR EL MAGISK PATCHED BOOT:
1. Extrae el archivo 'boot.img' del ZIP de la imagen de fábrica (dentro de image-bluejay-*.zip).
2. Pasa 'boot.img' al Pixel 6a e instálale la APK oficial de Magisk (https://github.com/topjohnwu/Magisk/releases).
3. Abre Magisk -> Instalar -> 'Seleccionar y parchar un archivo' -> selecciona 'boot.img'.
4. Magisk generará un archivo llamado 'magisk_patched-*.img' en la carpeta Downloads.
5. Copia ese archivo a tu PC.
6. Reinicia el Pixel 6a en modo Fastboot.
--------------------------------------------------------------------------------
"@ -ForegroundColor White
    $PatchedBootImgPath = Read-Host "Introduce la ruta completa al archivo magisk_patched-*.img"
}

if (-not (Test-Path $PatchedBootImgPath)) {
    Write-Host "[ERR] No se encontró el archivo en: $PatchedBootImgPath" -ForegroundColor Red
    exit 1
}

Write-Host "[+] Verificando dispositivo en modo Fastboot..." -ForegroundColor Cyan
$devices = & $fastbootPath devices
if (-not $devices) {
    Write-Host "[ERR] Pixel 6a no detectado en fastboot. Conéctalo y ponlo en fastboot." -ForegroundColor Red
    exit 1
}

Write-Host "[+] Flasheando boot.img parcheado en la partición 'boot'..." -ForegroundColor Cyan
& $fastbootPath flash boot "$PatchedBootImgPath"

Write-Host "[+] Reiniciando el dispositivo al sistema..." -ForegroundColor Green
& $fastbootPath reboot

Write-Host "`n[OK] Dispositivo reiniciado. Root con Magisk activo." -ForegroundColor Green
Write-Host "Siguiente paso: Habilitar Depuración por USB en Ajustes -> Opciones de Desarrollador." -ForegroundColor Yellow
