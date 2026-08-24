$ports = @(
    @{ name = "AdGuard Home"; port = 3000 },
    @{ name = "PixelPulse Dashboard"; port = 8080 },
    @{ name = "CubeCoders AMP"; port = 8085 },
    @{ name = "FileBrowser"; port = 8090 },
    @{ name = "PixelCinema Pro v2.0"; port = 8095 },
    @{ name = "Jellyfin Media Server"; port = 8096 }
)

Write-Host "=== ESTADO DE TODOS LOS SERVICIOS (192.168.1.135) ===" -ForegroundColor Cyan
foreach ($p in $ports) {
    try {
        $r = Invoke-WebRequest -Uri "http://192.168.1.135:$($p.port)" -TimeoutSec 2 -ErrorAction Stop
        Write-Host "  ✅ $($p.name) (Puerto $($p.port)): ONLINE (HTTP $($r.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $($p.name) (Puerto $($p.port)): OFFLINE ($_)" -ForegroundColor Yellow
    }
}
