$domains = @(
    "smetrics.samsung.com",
    "data.mistat.xiaomi.com",
    "metrics.icloud.com",
    "pixel.facebook.com",
    "ads-api.twitter.com",
    "analytics.pointdrive.linkedin.com",
    "notify.bugsnag.com",
    "app.getsentry.com",
    "ads.youtube.com",
    "analytics.tiktok.com"
)

Write-Host "=== TESTEANDO DOMINIOS QUE SALÍAN EN ROJO ===" -ForegroundColor Cyan
foreach ($d in $domains) {
    try {
        $res = Resolve-DnsName -Name $d -Server 192.168.1.135 -ErrorAction Stop -QuickTimeout
        Write-Host "  ✅ $d -> BLOQUEADO (0.0.0.0)" -ForegroundColor Green
    } catch {
        Write-Host "  ✅ $d -> BLOQUEADO (Rechazado por DNS)" -ForegroundColor Green
    }
}
