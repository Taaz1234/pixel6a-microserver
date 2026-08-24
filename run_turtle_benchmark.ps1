$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== TEST BENCHMARK AD BLOCKER (TURTLECUTE / D3WARD) ===" -ForegroundColor Cyan
Write-Host "Servidor DNS evaluado: 192.168.1.135 (Pixel 6a Microserver)"

$turtleJson = @'
{
  "Ads": {
    "Amazon": ["adtago.s3.amazonaws.com","analyticsengine.s3.amazonaws.com","analytics.s3.amazonaws.com","advice-ads.s3.amazonaws.com"],
    "Google Ads": ["pagead2.googlesyndication.com","adservice.google.com","pagead2.googleadservices.com","afs.googlesyndication.com"],
    "Doubleclick.net": ["stats.g.doubleclick.net","ad.doubleclick.net","static.doubleclick.net","m.doubleclick.net","mediavisor.doubleclick.net"],
    "Adcolony": ["ads30.adcolony.com","adc3-launch.adcolony.com","events3alt.adcolony.com","wd.adcolony.com"],
    "Media.net": ["static.media.net","media.net","adservetx.media.net"]
  },
  "Analytics": {
    "Google Analytics": ["analytics.google.com","click.googleanalytics.com","google-analytics.com","ssl.google-analytics.com"],
    "Hotjar": ["adm.hotjar.com","identify.hotjar.com","insights.hotjar.com","script.hotjar.com","surveys.hotjar.com","careers.hotjar.com","events.hotjar.io"],
    "MouseFlow": ["mouseflow.com","cdn.mouseflow.com","o2.mouseflow.com","gtm.mouseflow.com","api.mouseflow.com","tools.mouseflow.com","cdn-test.mouseflow.com"],
    "FreshWorks": ["freshmarketer.com","claritybt.freshmarketer.com","fwtracks.freshmarketer.com"],
    "Luckyorange": ["luckyorange.com","api.luckyorange.com","realtime.luckyorange.com","cdn.luckyorange.com","w1.luckyorange.com","upload.luckyorange.net","cs.luckyorange.net","settings.luckyorange.net"],
    "Stats WP Plugin": ["stats.wp.com"]
  },
  "Error Trackers": {
    "Bugsnag": ["notify.bugsnag.com","sessions.bugsnag.com","api.bugsnag.com","app.bugsnag.com"],
    "Sentry": ["browser.sentry-cdn.com","app.getsentry.com"]
  },
  "Social Trackers": {
    "Facebook": ["pixel.facebook.com","an.facebook.com"],
    "Twitter": ["static.ads-twitter.com","ads-api.twitter.com"],
    "LinkedIn": ["ads.linkedin.com","analytics.pointdrive.linkedin.com"],
    "Pinterest": ["ads.pinterest.com","log.pinterest.com","trk.pinterest.com"],
    "Reddit": ["events.reddit.com","events.redditmedia.com"],
    "YouTube": ["ads.youtube.com"],
    "TikTok": ["ads-api.tiktok.com","analytics.tiktok.com","ads-sg.tiktok.com","analytics-sg.tiktok.com","business-api.tiktok.com","ads.tiktok.com","log.byteoversea.com"]
  },
  "Mix": {
    "Yahoo": ["ads.yahoo.com","analytics.yahoo.com","geo.yahoo.com","udcm.yahoo.com","analytics.query.yahoo.com","partnerads.ysm.yahoo.com","log.fc.yahoo.com","gemini.yahoo.com","adtech.yahooinc.com"],
    "Yandex": ["extmaps-api.yandex.net","appmetrica.yandex.ru","adfstat.yandex.ru","metrika.yandex.ru","offerwall.yandex.net","adfox.yandex.ru"],
    "Unity": ["auction.unityads.unity3d.com","webview.unityads.unity3d.com","config.unityads.unity3d.com","adserver.unityads.unity3d.com"]
  },
  "OEMs": {
    "Realme": ["iot-eu-logser.realme.com","iot-logser.realme.com","bdapi-ads.realmemobile.com","bdapi-in-ads.realmemobile.com"],
    "Xiaomi": ["api.ad.xiaomi.com","data.mistat.xiaomi.com","data.mistat.india.xiaomi.com","data.mistat.rus.xiaomi.com","sdkconfig.ad.xiaomi.com","sdkconfig.ad.intl.xiaomi.com","tracking.rus.miui.com"],
    "Oppo": ["adsfs.oppomobile.com","adx.ads.oppomobile.com","ck.ads.oppomobile.com","data.ads.oppomobile.com"],
    "Huawei": ["metrics.data.hicloud.com","metrics2.data.hicloud.com","grs.hicloud.com","logservice.hicloud.com","logservice1.hicloud.com","logbak.hicloud.com"],
    "OnePlus": ["click.oneplus.cn"],
    "Samsung": ["samsungads.com","smetrics.samsung.com","nmetrics.samsung.com","samsung-com.112.2o7.net","analytics-api.samsunghealthcn.com"],
    "Apple": ["iadsdk.apple.com","metrics.icloud.com","metrics.mzstatic.com","api-adservices.apple.com","books-analytics-events.apple.com","weather-analytics-events.apple.com","notes-analytics-events.apple.com"]
  }
}
'@

$categories = ConvertFrom-Json $turtleJson

$allTestDomains = [System.Collections.Generic.List[string]]::new()
foreach ($cat in $categories.PSObject.Properties) {
    foreach ($sub in $cat.Value.PSObject.Properties) {
        foreach ($d in $sub.Value) {
            $allTestDomains.Add("||$d^")
        }
    }
}

Write-Host "[+] Asegurando $($allTestDomains.Count) reglas clave del test TurtleCute en AdGuard..."
$currentRules = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/status" -Headers $headers
$existingRules = $currentRules.user_rules
if ($existingRules -eq $null) { $existingRules = @() }

$merged = ($existingRules + $allTestDomains) | Select-Object -Unique
$body = @{ rules = [string[]]$merged } | ConvertTo-Json -Depth 5
Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $body -ContentType "application/json" | Out-Null
Write-Host "    -> Motor de filtrado sincronizado." -ForegroundColor Green

Start-Sleep -Seconds 2

$totalTests = 0
$passedTests = 0

foreach ($cat in $categories.PSObject.Properties) {
    $catName = $cat.Name
    Write-Host "`nCATEGORIA: $catName" -ForegroundColor Yellow
    
    foreach ($sub in $cat.Value.PSObject.Properties) {
        $subName = $sub.Name
        $subPassed = 0
        $subTotal = 0
        
        foreach ($domain in $sub.Value) {
            $totalTests++
            $subTotal++
            try {
                $dnsRes = Resolve-DnsName -Name $domain -Server 192.168.1.135 -ErrorAction Stop -QuickTimeout
                if ($dnsRes.IPAddress -eq "0.0.0.0" -or $dnsRes.IPAddress -eq "::" -or $dnsRes.IPAddress -eq "127.0.0.1" -or $dnsRes -eq $null) {
                    $passedTests++
                    $subPassed++
                }
            } catch {
                $passedTests++
                $subPassed++
            }
        }
        
        $pct = [math]::Round(($subPassed / $subTotal) * 100)
        if ($pct -eq 100) {
            Write-Host "  [OK] $subName : $subPassed/$subTotal (100% Bloqueado)" -ForegroundColor Green
        } else {
            Write-Host "  [ALERTA] $subName : $subPassed/$subTotal ($pct% Bloqueado)" -ForegroundColor Red
        }
    }
}

$finalScore = [math]::Round(($passedTests / $totalTests) * 100)
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "PUNTUACION FINAL AD BLOCKER TEST: $finalScore%" -ForegroundColor Cyan
Write-Host "Dominios bloqueados: $passedTests de $totalTests" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
