Write-Host "=== BUSCANDO CHUCKY EN CASTELLANO (TEMPORADAS 1, 2 Y 3) ===" -ForegroundColor Cyan

$spQueries = @(
    "Chucky Castellano",
    "Chucky S01 Castellano",
    "Chucky Temporada 1",
    "Chucky Temporada 2",
    "Chucky Temporada 3",
    "Chucky Dual"
)

$results = @()
foreach ($q in $spQueries) {
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

$unique = $results | Sort-Object -Property seeders -Descending | Select-Object -Unique -Property name, infohash, size_bytes, seeders

foreach ($item in ($unique | Select-Object -First 10)) {
    $gb = [math]::Round($item.size_bytes / 1GB, 2)
    Write-Host "• $($item.name) | $gb GB | Seeds: $($item.seeders) | Hash: $($item.infohash)" -ForegroundColor Green
}
