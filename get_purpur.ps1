Write-Host "=== CONSULTANDO ÚLTIMA VERSIÓN DE PURPUR / PAPERMC 1.21 ===" -ForegroundColor Cyan

$purpur = Invoke-RestMethod -Uri "https://api.purpurmc.org/v2/purpur"
$latestVer = $purpur.versions[-1]
Write-Host "[+] Última versión de Purpur MC: $latestVer" -ForegroundColor Green
$downloadUrl = "https://api.purpurmc.org/v2/purpur/$latestVer/latest/download"
Write-Host "[+] URL de descarga: $downloadUrl" -ForegroundColor Yellow
