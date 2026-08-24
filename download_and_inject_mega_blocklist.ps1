$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== DESCARGANDO LAS MEJORES LISTAS GLOBALES DE BLOQUEO (2026) ===" -ForegroundColor Cyan

$filterDir = "dashboard\filters"
if (!(Test-Path $filterDir)) {
    New-Item -ItemType Directory -Path $filterDir -Force | Out-Null
}

$megaLists = @(
    @{
        name = "HaGeZi Multi PRO++ (Bloqueo Maximo Inteligente)"
        file = "$filterDir\hagezi_pro_plus.txt"
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.txt"
    },
    @{
        name = "HaGeZi Threat Intelligence Feeds (Malware, Phishing, Ransomware)"
        file = "$filterDir\hagezi_tif.txt"
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
    },
    @{
        name = "OISD Big (Anti-Spam y Publicidad)"
        file = "$filterDir\oisd_big.txt"
        url = "https://big.oisd.nl"
    },
    @{
        name = "1Hosts Pro (Bloqueo Avanzado de Rastreadores)"
        file = "$filterDir\1hosts_pro.txt"
        url = "https://raw.githubusercontent.com/badmojr/1Hosts/master/Pro/adblock.txt"
    },
    @{
        name = "Perflyst SmartTV (Samsung, LG, Sony, Xiaomi, Roku)"
        file = "$filterDir\smarttv.txt"
        url = "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt"
    },
    @{
        name = "WindowsSpyBlocker (Telemetria de Windows y Microsoft)"
        file = "$filterDir\windows_spy.txt"
        url = "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
    },
    @{
        name = "URLHaus (Proteccion contra Malware y Troyanos)"
        file = "$filterDir\urlhaus.txt"
        url = "https://urlhaus.abuse.ch/downloads/hostfile/"
    },
    @{
        name = "Dandelion Sprout (Consolas de Juegos: PS5, Xbox, Switch)"
        file = "$filterDir\consoles.txt"
        url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/GameConsoleAdblockList.txt"
    }
)

foreach ($item in $megaLists) {
    Write-Host "[+] Descargando $($item.name)..."
    try {
        Invoke-WebRequest -Uri $item.url -OutFile $item.file -TimeoutSec 30
        $lines = (Get-Content $item.file | Measure-Object -Line).Lines
        Write-Host "    -> OK ($lines registros descargados)" -ForegroundColor Green
    } catch {
        Write-Host "    -> Error al descargar: $_" -ForegroundColor Yellow
    }
}

Write-Host "`n=== PROCESANDO Y COMPILANDO REGLAS DE FORMA ULTRA RAPIDA ===" -ForegroundColor Cyan

$uniqueRules = [System.Collections.Generic.HashSet[string]]::new()

function Process-File([string]$path, [int]$limit = 25000) {
    if (Test-Path $path) {
        $count = 0
        foreach ($line in [System.IO.File]::ReadLines((Resolve-Path $path))) {
            $trimmed = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#") -or $trimmed.StartsWith("!")) {
                continue
            }
            if ($trimmed.StartsWith("0.0.0.0 ") -or $trimmed.StartsWith("127.0.0.1 ")) {
                $parts = $trimmed -split '\s+'
                if ($parts.Count -ge 2 -and $parts[1] -ne "localhost" -and $parts[1] -ne "broadcasthost") {
                    $uniqueRules.Add("||" + $parts[1] + "^") | Out-Null
                    $count++
                }
            } elseif ($trimmed.StartsWith("||")) {
                $uniqueRules.Add($trimmed) | Out-Null
                $count++
            } else {
                if ($trimmed -notmatch "^[\d\.:]") {
                    $uniqueRules.Add("||" + $trimmed + "^") | Out-Null
                    $count++
                }
            }
            if ($count -ge $limit) { break }
        }
        $msg = "  [+] " + $path + " : procesadas " + $count + " reglas"
        Write-Host $msg -ForegroundColor Green
    }
}

Process-File "$filterDir\adguard_dns.txt" 25000
Process-File "$filterDir\hagezi_pro_plus.txt" 25000
Process-File "$filterDir\hagezi_tif.txt" 20000
Process-File "$filterDir\oisd_big.txt" 20000
Process-File "$filterDir\1hosts_pro.txt" 20000
Process-File "$filterDir\smarttv.txt" 5000
Process-File "$filterDir\windows_spy.txt" 5000
Process-File "$filterDir\urlhaus.txt" 10000
Process-File "$filterDir\consoles.txt" 5000
Process-File "$filterDir\easylist_spanish.txt" 5000

$criticalExtra = @(
    "||mask.icloud.com^", "||mask-h2.icloud.com^", "||mask-api.icloud.com^",
    "||dns.google^", "||cloudflare-dns.com^", "||chrome.cloudflare-dns.com^",
    "||doubleclick.net^", "||googleads.g.doubleclick.net^", "||pagead2.googlesyndication.com^",
    "||samsungads.com^", "||lgsmartad.com^", "||api.ad.xiaomi.com^", "||tracking.rus.miui.com^",
    "||criteo.com^", "||taboola.com^", "||outbrain.com^", "||scorecardresearch.com^",
    "||adnxs.com^", "||adcolony.com^", "||media.net^", "||analytics.google.com^",
    "||mouseflow.com^", "||hotjar.com^", "||luckyorange.com^", "||freshmarketer.com^",
    "||pixel.facebook.com^", "||ads-twitter.com^", "||ads.linkedin.com^", "||ads.pinterest.com^",
    "||ads.tiktok.com^", "||analytics.tiktok.com^", "||unityads.unity3d.com^"
)
foreach ($r in $criticalExtra) { $uniqueRules.Add($r) | Out-Null }

Write-Host "`n[+] TOTAL DE REGLAS UNICAS OPTIMIZADAS: $($uniqueRules.Count)" -ForegroundColor Green

Write-Host "[+] Enviando e instalando el Mega Pack en AdGuard Home..." -ForegroundColor Cyan
$rulesArray = [string[]]$uniqueRules
$body = @{
    rules = $rulesArray
} | ConvertTo-Json -Depth 5

try {
    $res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $body -ContentType "application/json"
    Write-Host "    -> [OK] Mega Pack de $($uniqueRules.Count) reglas instalado y activo con exito!" -ForegroundColor Green
} catch {
    Write-Host "    -> Error al enviar: $_" -ForegroundColor Red
}

Write-Host "`n=== COMPROBANDO ESTADO DEL SERVIDOR ADGUARD HOME ===" -ForegroundColor Cyan
$stats = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/stats" -Headers $headers
Write-Host "Peticiones DNS procesadas:" $stats.num_dns_queries
Write-Host "Peticiones Bloqueadas:" $stats.num_blocked_filtering
Write-Host "Porcentaje bloqueado:" "$([math]::Round(($stats.num_blocked_filtering / [math]::Max(1, $stats.num_dns_queries))*100))%"
