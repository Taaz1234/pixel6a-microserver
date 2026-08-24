$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== AÑADIENDO REGLAS DE LISTA BLANCA (ALLOWLIST) EN ADGUARD ===" -ForegroundColor Cyan

# Dominios esenciales que NUNCA deben ser bloqueados
$allowRules = @(
    "@@||googleapis.com^",
    "@@||daily-cloudcode-pa.googleapis.com^",
    "@@||cloudcode-pa.googleapis.com^",
    "@@||google.com^",
    "@@||gstatic.com^",
    "@@||googleusercontent.com^",
    "@@||gemini.google.com^",
    "@@||generativelanguage.googleapis.com^"
)

$currentRules = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/status" -Headers $headers
$rules = [System.Collections.Generic.HashSet[string]]::new()

# Añadir las reglas de whitelist primero
foreach ($a in $allowRules) {
    $rules.Add($a) | Out-Null
}

foreach ($r in $currentRules.user_rules) {
    if (![string]::IsNullOrWhiteSpace($r)) {
        # Si no bloquea googleapis
        if ($r -notlike "*daily-cloudcode*" -and $r -notlike "*googleapis*") {
            $rules.Add($r) | Out-Null
        }
    }
}

$body = @{
    rules = [string[]]$rules
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $body -ContentType "application/json" | Out-Null
Write-Host "[+] Whitelist de Google Cloud APIs añadida con éxito en AdGuard." -ForegroundColor Green

# Probar resolución
$res = Resolve-DnsName -Name "daily-cloudcode-pa.googleapis.com" -Server 192.168.1.135 -ErrorAction SilentlyContinue
Write-Host "Resolución de daily-cloudcode-pa.googleapis.com:" ($res.IPAddress -join ', ') -ForegroundColor Green
