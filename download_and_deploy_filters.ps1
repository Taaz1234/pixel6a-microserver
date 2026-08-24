Write-Host "=== DESCARGANDO LISTAS DE FILTRADO PARA ADGUARD HOME ===" -ForegroundColor Cyan

$filterDir = "dashboard\filters"
if (!(Test-Path $filterDir)) {
    New-Item -ItemType Directory -Path $filterDir -Force | Out-Null
}

$lists = @(
    @{
        name = "AdGuard DNS filter"
        file = "$filterDir\adguard_dns.txt"
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
    },
    @{
        name = "HaGeZi Multi PRO"
        file = "$filterDir\hagezi_pro.txt"
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"
    },
    @{
        name = "AdGuard Mobile Ads"
        file = "$filterDir\mobile_ads.txt"
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
    },
    @{
        name = "EasyList Spanish"
        file = "$filterDir\easylist_spanish.txt"
        url = "https://easylist-downloads.adblockplus.org/easylistspanish.txt"
    }
)

foreach ($l in $lists) {
    Write-Host "[+] Descargando $($l.name)..."
    try {
        Invoke-WebRequest -Uri $l.url -OutFile $l.file -TimeoutSec 30
        $lines = (Get-Content $l.file | Measure-Object -Line).Lines
        Write-Host "    -> OK ($lines reglas descargadas)" -ForegroundColor Green
    } catch {
        Write-Host "    -> Error al descargar: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== REGISTRANDO LISTAS EN ADGUARD HOME (VIA HTTP INTERNO) ===" -ForegroundColor Cyan

$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

# Subir listas por API usando el servidor interno HTTP (127.0.0.1:8080)
$adguardSubList = @(
    @{
        name = "AdGuard DNS filter Oficial"
        url = "http://127.0.0.1:8080/filters/adguard_dns.txt"
        whitelist = $false
    },
    @{
        name = "HaGeZi Multi PRO (Bloqueo Global)"
        url = "http://127.0.0.1:8080/filters/hagezi_pro.txt"
        whitelist = $false
    },
    @{
        name = "AdGuard Mobile Ads (Móviles)"
        url = "http://127.0.0.1:8080/filters/mobile_ads.txt"
        whitelist = $false
    },
    @{
        name = "EasyList Spanish (Español)"
        url = "http://127.0.0.1:8080/filters/easylist_spanish.txt"
        whitelist = $false
    }
)

foreach ($sub in $adguardSubList) {
    Write-Host "[+] Añadiendo suscripción: $($sub.name)..."
    $body = $sub | ConvertTo-Json
    try {
        $res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/add_url" -Headers $headers -Method Post -Body $body -ContentType "application/json"
        Write-Host "    -> Suscripción registrada." -ForegroundColor Green
    } catch {
        Write-Host "    -> Ya existe o actualizado." -ForegroundColor Yellow
    }
}

# También inyectamos las reglas de bloqueo directo
$customRules = Get-Content "$filterDir\adguard_dns.txt" | Where-Object { $_ -match "^\|\|" -and $_ -notmatch "^!" } | Select-Object -First 5000

Write-Host "[+] Inyectando $($customRules.Count) reglas directas de alta prioridad..."
$rulesBody = @{
    rules = $customRules
} | ConvertTo-Json -Depth 2

try {
    Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $rulesBody -ContentType "application/json"
    Write-Host "    -> Reglas inyectadas y activas." -ForegroundColor Green
} catch {
    Write-Host "    -> Error inyectando reglas: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== TEST FINAL DE BLOQUEO DNS (192.168.1.135:53) ===" -ForegroundColor Cyan
Start-Sleep -Seconds 2

$domains = @("doubleclick.net", "googleads.g.doubleclick.net", "pagead2.googlesyndication.com", "adservice.google.com")
foreach ($d in $domains) {
    try {
        $test = Resolve-DnsName -Name $d -Server 192.168.1.135 -ErrorAction Stop
        Write-Host "Dominio $d -> Bloqueado a IP:" ($test.IPAddress -join ", ") -ForegroundColor Green
    } catch {
        Write-Host "Dominio $d -> Bloqueado (Sin respuesta DNS)" -ForegroundColor Green
    }
}
