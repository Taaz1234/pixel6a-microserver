param (
    [switch]$SkipDownloadTools,
    [switch]$UnlockBootloader,
    [string]$FactoryZipPath = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WorkDir = Join-Path (Split-Path -Parent $ScriptDir) "platform-tools"

function Write-Step ($msg) {
    Write-Host "[+] $msg" -ForegroundColor Cyan
}
function Write-Success ($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}
function Write-Warn ($msg) {
    Write-Host "[WARN] $msg" -ForegroundColor Yellow
}
function Write-Err ($msg) {
    Write-Host "[ERR] $msg" -ForegroundColor Red
}

# 1. Asegurar Android Platform-Tools
Write-Step "Verificando disponibilidad de fastboot en el sistema..."
$fastbootCmd = Get-Command fastboot -ErrorAction SilentlyContinue
if (-not $fastbootCmd -and -not $SkipDownloadTools) {
    $fbExe = Join-Path $WorkDir "fastboot.exe"
    if (-not (Test-Path $fbExe)) {
        Write-Warn "Fastboot no encontrado. Descargando Google Platform-Tools..."
        $zipUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
        $zipFile = Join-Path (Split-Path -Parent $ScriptDir) "platform-tools.zip"
        
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
        
        $extractDir = Split-Path -Parent $ScriptDir
        Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
        Remove-Item $zipFile -Force
        Write-Success "Platform-Tools instalado en: $WorkDir"
    }
    $env:PATH = "$WorkDir;$env:PATH"
    $fastbootPath = Join-Path $WorkDir "fastboot.exe"
} else {
    $fastbootPath = "fastboot"
}

# 2. Deteccion de Fastboot Devices
Write-Step "Escaneando dispositivos conectados en modo Fastboot..."
$devices = & $fastbootPath devices
if (-not $devices) {
    Write-Err "No se detecto ningun dispositivo en modo Fastboot."
    Write-Host "Por favor, pon el Pixel 6a en modo Fastboot (Bajar Volumen + Encendido) y conectalo por USB." -ForegroundColor Yellow
    exit 1
}

Write-Success "Dispositivo detectado:"
Write-Host $devices

# 3. Verificacion de Hardware
Write-Step "Consultando variables del dispositivo..."
$product = & $fastbootPath getvar product 2>&1 | Out-String
Write-Host $product

$unlocked = & $fastbootPath getvar unlocked 2>&1 | Out-String
Write-Host $unlocked

if ($UnlockBootloader -or ($unlocked -match "unlocked:\s*no")) {
    Write-Warn "El bootloader esta BLOQUEADO. Solicitando desbloqueo..."
    Write-Host "ATENCION: En la pantalla del Pixel 6a, usa Volumen para seleccionar 'Unlock the bootloader' y confirma con Encendido." -ForegroundColor Yellow
    & $fastbootPath flashing unlock
}

# 4. Flasheo de Factory Image
if ($FactoryZipPath -and (Test-Path $FactoryZipPath)) {
    Write-Step "Descomprimiendo y ejecutando flash-all desde: $FactoryZipPath"
    $tempExtract = Join-Path (Split-Path -Parent $ScriptDir) "factory_image_temp"
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
    
    Expand-Archive -Path $FactoryZipPath -DestinationPath $tempExtract
    $flashAllScript = Get-ChildItem -Path $tempExtract -Filter "flash-all.bat" -Recurse | Select-Object -First 1
    
    if ($flashAllScript) {
        Write-Step "Ejecutando $($flashAllScript.FullName)..."
        Push-Location $flashAllScript.DirectoryName
        & .\flash-all.bat
        Pop-Location
        Write-Success "Flasheo completado con exito."
    } else {
        Write-Err "No se encontro flash-all.bat dentro del ZIP proporcionado."
    }
}
