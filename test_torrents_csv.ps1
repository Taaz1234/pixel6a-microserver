$queries = @("Gladiator", "Deadpool", "Oppenheimer", "Batman")

foreach ($q in $queries) {
    Write-Host "=== Searching Torrents-CSV for: $q ==="
    $url = "https://torrents-csv.com/service/search?q=" + [System.Uri]::EscapeDataString($q) + "&size=10"
    try {
        $res = Invoke-RestMethod -Uri $url -UserAgent "Mozilla/5.0"
        foreach ($item in $res.torrents | Select-Object -First 3) {
            $sizeGB = [Math]::Round([double]$item.size_bytes / (1024*1024*1024), 2)
            Write-Host "  -> Title: $($item.name)"
            Write-Host "     Size: $sizeGB GB | Seeds: $($item.seeders) | Hash: $($item.infohash)"
        }
    } catch {
        Write-Host "Error: $_"
    }
}
