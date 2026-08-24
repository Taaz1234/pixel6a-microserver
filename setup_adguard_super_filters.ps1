$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== INSTALANDO LISTAS DE BLOQUEO EN ADGUARD HOME ===" -ForegroundColor Cyan

$lists = @(
    @{
        name = "AdGuard DNS filter Oficial"
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
        whitelist = $false
    },
    @{
        name = "HaGeZi Multi PRO"
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"
        whitelist = $false
    },
    @{
        name = "AdGuard Mobile Ads Filter"
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
        whitelist = $false
    },
    @{
        name = "EasyList Spanish"
        url = "https://easylist-downloads.adblockplus.org/easylistspanish.txt"
        whitelist = $false
    },
    @{
        name = "OISD Big"
        url = "https://big.oisd.nl"
        whitelist = $false
    },
    @{
        name = "NoCoin Filter"
        url = "https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt"
        whitelist = $false
    }
)

foreach ($l in $lists) {
    Write-Host "[+] Descargando y añadiendo: $($l.name)..."
    $body = $l | ConvertTo-Json
    try {
        $res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/add_url" -Headers $headers -Method Post -Body $body -ContentType "application/json"
        Write-Host "    -> OK: $($res | ConvertTo-Json -Compress)" -ForegroundColor Green
    } catch {
        Write-Host "    -> Nota: $_" -ForegroundColor Yellow
    }
}

Write-Host "[+] Forzando recarga y compilación de filtros..."
$ref = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/refresh" -Headers $headers -Method Post -Body '{"whitelist":false}' -ContentType "application/json"
Write-Host "Resultado:" ($ref | ConvertTo-Json -Compress)

Start-Sleep -Seconds 3

# Comprobar estadísticas
$res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/status" -Headers @{Authorization="Basic $base64"}
Write-Host ""
Write-Host "=== ESTADÍSTICAS FINALES ===" -ForegroundColor Cyan
foreach ($f in $res.filters) {
    Write-Host "  - $($f.name): $($f.rules_count) reglas activas"
}
$total = ($res.filters | Measure-Object -Property rules_count -Sum).Sum
Write-Host "TOTAL REGLAS DE BLOQUEO ACTIVAS:" $total -ForegroundColor Green
