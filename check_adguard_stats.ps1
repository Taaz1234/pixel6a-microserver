$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/status" -Headers @{Authorization="Basic $base64"}

Write-Host "=== ESTADÍSTICAS DE ADGUARD HOME ===" -ForegroundColor Cyan
Write-Host "Filtros instalados:" $res.filters.Count
foreach ($f in $res.filters) {
    Write-Host "  - $($f.name): $($f.rules_count) reglas (Habilitado: $($f.enabled))"
}
$total = ($res.filters | Measure-Object -Property rules_count -Sum).Sum
Write-Host "TOTAL REGLAS DE BLOQUEO:" $total -ForegroundColor Green
