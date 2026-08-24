$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== CONFIGURANDO ADGUARD PARA IPHONE / IOS ===" -ForegroundColor Cyan

# Reglas oficiales para desactivar el bypass de Apple Private Relay y forzar uso de AdGuard
$iosRules = @(
    "||mask.icloud.com^",
    "||mask-h2.icloud.com^",
    "||mask-api.icloud.com^",
    "||mask-tfo.icloud.com^"
)

$currentRules = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/status" -Headers $headers
$rules = [System.Collections.Generic.HashSet[string]]::new()
foreach ($r in $currentRules.user_rules) {
    if (![string]::IsNullOrWhiteSpace($r)) {
        $rules.Add($r) | Out-Null
    }
}
foreach ($ir in $iosRules) {
    $rules.Add($ir) | Out-Null
}

$body = @{
    rules = [string[]]$rules
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $body -ContentType "application/json" | Out-Null
Write-Host "[+] Bloqueo de Bypass de iCloud Private Relay activado en AdGuard." -ForegroundColor Green
