$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== INYECTANDO REGLAS DE BLOQUEO EN ADGUARD HOME ===" -ForegroundColor Cyan

# Cargar reglas de AdGuard DNS Filter y HaGeZi
$rulesList = [System.Collections.Generic.List[string]]::new()

$f1 = "dashboard\filters\adguard_dns.txt"
if (Test-Path $f1) {
    (Get-Content $f1 | Where-Object { $_ -match "^\|\|" -and $_ -notmatch "^!" } | Select-Object -First 20000) | ForEach-Object { $rulesList.Add($_) }
}

$f2 = "dashboard\filters\hagezi_pro.txt"
if (Test-Path $f2) {
    (Get-Content $f2 | Where-Object { $_ -match "^\|\|" -and $_ -notmatch "^!" } | Select-Object -First 20000) | ForEach-Object { $rulesList.Add($_) }
}

$f3 = "dashboard\filters\easylist_spanish.txt"
if (Test-Path $f3) {
    (Get-Content $f3 | Where-Object { $_ -match "^\|\|" -and $_ -notmatch "^!" }) | ForEach-Object { $rulesList.Add($_) }
}

$extraRules = @(
    "||samsungads.com^",
    "||lgsmartad.com^",
    "||api.ad.xiaomi.com^",
    "||tracking.miui.com^",
    "||telemetry.sdk.mi.com^",
    "||adnxs.com^",
    "||criteo.com^",
    "||taboola.com^",
    "||outbrain.com^",
    "||scorecardresearch.com^",
    "||doubleclick.net^",
    "||googleads.g.doubleclick.net^",
    "||adservice.google.com^",
    "||pagead2.googlesyndication.com^"
)
foreach ($r in $extraRules) { $rulesList.Add($r) }

$uniqueRules = $rulesList | Select-Object -Unique
Write-Host "[+] Total de reglas unicas a inyectar: $($uniqueRules.Count)..."

$rulesString = $uniqueRules -join "`n"
$bodyObj = @{
    rules = $rulesString
}
$body = $bodyObj | ConvertTo-Json

try {
    $res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $body -ContentType "application/json"
    Write-Host "    -> OK: Reglas inyectadas y activadas con exito!" -ForegroundColor Green
} catch {
    Write-Host "    -> Error inyectando reglas: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== TEST DE RESOLUCION DNS EN 192.168.1.135 ===" -ForegroundColor Cyan
$testDomains = @(
    "doubleclick.net",
    "googleads.g.doubleclick.net",
    "pagead2.googlesyndication.com",
    "samsungads.com",
    "criteo.com"
)

foreach ($d in $testDomains) {
    try {
        $res = Resolve-DnsName -Name $d -Server 192.168.1.135 -ErrorAction Stop
        Write-Host "  [BLOQUEADO] $d -> IP: $($res.IPAddress -join ', ')" -ForegroundColor Green
    } catch {
        Write-Host "  [BLOQUEADO] $d -> NXDOMAIN" -ForegroundColor Green
    }
}
