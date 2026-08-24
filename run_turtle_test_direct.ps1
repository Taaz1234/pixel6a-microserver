Write-Host "=== RESULTADOS AD BLOCKER TEST (adblock.turtlecute.org) ===" -ForegroundColor Cyan
Write-Host "DNS Evaluado: 192.168.1.135 (AdGuard Home en Google Pixel 6a)`n"

$turtleJson = @'
{
  "Ads (Publicidad y Banners)": {
    "Amazon Ads": ["adtago.s3.amazonaws.com","analyticsengine.s3.amazonaws.com","analytics.s3.amazonaws.com","advice-ads.s3.amazonaws.com"],
    "Google Ads": ["pagead2.googlesyndication.com","adservice.google.com","pagead2.googleadservices.com","afs.googlesyndication.com"],
    "Doubleclick": ["stats.g.doubleclick.net","ad.doubleclick.net","static.doubleclick.net","m.doubleclick.net","mediavisor.doubleclick.net"],
    "Adcolony": ["ads30.adcolony.com","adc3-launch.adcolony.com","events3alt.adcolony.com","wd.adcolony.com"],
    "Media.net": ["static.media.net","media.net","adservetx.media.net"]
  },
  "Analytics (Rastreadores Web)": {
    "Google Analytics": ["analytics.google.com","click.googleanalytics.com","google-analytics.com","ssl.google-analytics.com"],
    "Hotjar": ["adm.hotjar.com","identify.hotjar.com","insights.hotjar.com","script.hotjar.com","surveys.hotjar.com","careers.hotjar.com","events.hotjar.io"],
    "MouseFlow": ["mouseflow.com","cdn.mouseflow.com","o2.mouseflow.com","gtm.mouseflow.com","api.mouseflow.com","tools.mouseflow.com","cdn-test.mouseflow.com"],
    "FreshWorks": ["freshmarketer.com","claritybt.freshmarketer.com","fwtracks.freshmarketer.com"],
    "Luckyorange": ["luckyorange.com","api.luckyorange.com","realtime.luckyorange.com","cdn.luckyorange.com","w1.luckyorange.com","upload.luckyorange.net","cs.luckyorange.net","settings.luckyorange.net"],
    "Stats WP Plugin": ["stats.wp.com"]
  },
  "Social Trackers (Redes Sociales)": {
    "Facebook Pixel": ["pixel.facebook.com","an.facebook.com"],
    "Twitter / X Ads": ["static.ads-twitter.com","ads-api.twitter.com"],
    "LinkedIn Ads": ["ads.linkedin.com","analytics.pointdrive.linkedin.com"],
    "Pinterest": ["ads.pinterest.com","log.pinterest.com","trk.pinterest.com"],
    "Reddit": ["events.reddit.com","events.redditmedia.com"],
    "YouTube Ads": ["ads.youtube.com"],
    "TikTok Ads": ["ads-api.tiktok.com","analytics.tiktok.com","ads-sg.tiktok.com","analytics-sg.tiktok.com","business-api.tiktok.com","ads.tiktok.com","log.byteoversea.com"]
  },
  "OEMs (Telemetria de Fabricantes)": {
    "Xiaomi / MIUI": ["api.ad.xiaomi.com","data.mistat.xiaomi.com","sdkconfig.ad.xiaomi.com","tracking.rus.miui.com"],
    "Samsung Ads": ["samsungads.com","smetrics.samsung.com","nmetrics.samsung.com"],
    "Huawei": ["metrics.data.hicloud.com","metrics2.data.hicloud.com","logservice.hicloud.com"],
    "Apple Ads": ["iadsdk.apple.com","metrics.icloud.com","api-adservices.apple.com"]
  }
}
'@

$categories = ConvertFrom-Json $turtleJson
$totalDomains = 0
$blockedDomains = 0

foreach ($cat in $categories.PSObject.Properties) {
    $catName = $cat.Name
    Write-Host "`nCATEGORIA: $catName" -ForegroundColor Yellow
    
    foreach ($sub in $cat.Value.PSObject.Properties) {
        $subName = $sub.Name
        $subTotal = 0
        $subBlocked = 0
        
        foreach ($d in $sub.Value) {
            $totalDomains++
            $subTotal++
            try {
                $res = Resolve-DnsName -Name $d -Server 192.168.1.135 -ErrorAction Stop -QuickTimeout
                if ($res.IPAddress -eq "0.0.0.0" -or $res.IPAddress -eq "::" -or $res.IPAddress -eq "127.0.0.1" -or $res -eq $null) {
                    $blockedDomains++
                    $subBlocked++
                }
            } catch {
                $blockedDomains++
                $subBlocked++
            }
        }
        
        $percent = [math]::Round(($subBlocked / $subTotal) * 100)
        $msg = "  [OK] " + $subName + ": " + $subBlocked + "/" + $subTotal + " (" + $percent + "% bloqueado)"
        if ($percent -ge 90) {
            Write-Host $msg -ForegroundColor Green
        } else {
            Write-Host $msg -ForegroundColor Red
        }
    }
}

$score = [math]::Round(($blockedDomains / $totalDomains) * 100)
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "PUNTUACION TOTAL AD BLOCKER TEST: $score%" -ForegroundColor Cyan
Write-Host "Total peticiones bloqueadas: $blockedDomains de $totalDomains" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
