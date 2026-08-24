Write-Host "=== BUSCANDO LA SERIE 'CHUCKY' EN ESPAÑOL ===" -ForegroundColor Cyan

$queries = @(
    "Chucky Castellano",
    "Chucky Spanish",
    "Chucky Temporada",
    "Chucky 1080p"
)

$results = @()

foreach ($q in $queries) {
    try {
        $p1 = Invoke-RestMethod -Uri "https://torrents-csv.com/service/search?q=$([uri]::EscapeDataString($q))&size=20" -TimeoutSec 5
        if ($p1.torrents) { $results += $p1.torrents }
    } catch {}
    
    try {
        $p2 = Invoke-RestMethod -Uri "https://apibay.org/q.php?q=$([uri]::EscapeDataString($q))" -TimeoutSec 5
        if ($p2 -is [array]) {
            foreach ($t in $p2) {
                if ($t.name -and $t.name -ne "No results returned") {
                    $results += [PSCustomObject]@{
                        name = $t.name
                        infohash = $t.info_hash
                        size_bytes = [int64]$t.size
                        seeders = [int]$t.seeders
                    }
                }
            }
        }
    } catch {}
}

# Filtrar duplicados y ordenar por semillas
$unique = $results | Sort-Object -Property seeders -Descending | Select-Object -Unique -Property name, infohash, size_bytes, seeders

Write-Host "`n[+] RESULTADOS ENCONTRADOS PARA 'CHUCKY':" -ForegroundColor Green
$count = 1
foreach ($item in ($unique | Select-Object -First 10)) {
    $gb = [math]::Round($item.size_bytes / 1GB, 2)
    Write-Host "[$count] $($item.name)" -ForegroundColor White
    Write-Host "    Tamaño: $gb GB | Semillas: $($item.seeders) | Hash: $($item.infohash)" -ForegroundColor Yellow
    $count++
}
