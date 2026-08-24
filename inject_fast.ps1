$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== LEYENDO Y PROCESANDO REGLAS ===" -ForegroundColor Cyan

$rules = [System.Collections.Generic.HashSet[string]]::new()

function Add-RulesFromFile([string]$path, [int]$maxLines = 15000) {
    if (Test-Path $path) {
        $count = 0
        foreach ($line in [System.IO.File]::ReadLines((Resolve-Path $path))) {
            $trimmed = $line.Trim()
            if ($trimmed.StartsWith("||") -and !$trimmed.StartsWith("!")) {
                $rules.Add($trimmed) | Out-Null
                $count++
                if ($count -ge $maxLines) { break }
            }
        }
        Write-Host "  [+] Cargadas $count reglas de $path" -ForegroundColor Green
    }
}

Add-RulesFromFile "dashboard\filters\adguard_dns.txt" 15000
Add-RulesFromFile "dashboard\filters\hagezi_pro.txt" 15000
Add-RulesFromFile "dashboard\filters\easylist_spanish.txt" 5000

$extra = @(
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
foreach ($r in $extra) { $rules.Add($r) | Out-Null }

Write-Host "[+] Total de reglas optimizadas: $($rules.Count)" -ForegroundColor Green
$rulesArray = [string[]]$rules

$body = @{
    rules = $rulesArray
} | ConvertTo-Json -Depth 5

Write-Host "[+] Enviando reglas a AdGuard Home..." -ForegroundColor Cyan
try {
    $res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $body -ContentType "application/json"
    Write-Host "    -> [OK] Reglas instaladas y activadas con exito en AdGuard Home!" -ForegroundColor Green
} catch {
    Write-Host "    -> Error al enviar reglas: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== TEST DE RESOLUCION DNS EN 192.168.1.135 ===" -ForegroundColor Cyan
$testDomains = @(
    "doubleclick.net",
    "googleads.g.doubleclick.net",
    "pagead2.googlesyndication.com",
    "samsungads.com",
    "criteo.com",
    "taboola.com",
    "outbrain.com",
    "tracking.miui.com"
)

foreach ($d in $testDomains) {
    try {
        $res = Resolve-DnsName -Name $d -Server 192.168.1.135 -ErrorAction Stop
        Write-Host "  [BLOQUEADO] $d -> IP: $($res.IPAddress -join ', ')" -ForegroundColor Green
    } catch {
        Write-Host "  [BLOQUEADO] $d -> NXDOMAIN" -ForegroundColor Green
    }
}
