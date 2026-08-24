$queries = @("Gladiator", "Avatar", "Deadpool", "Oppenheimer")

foreach ($q in $queries) {
    Write-Host "=== Searching Real Torrents for: $q ==="
    $url = "https://apibay.org/q.php?q=" + [System.Uri]::EscapeDataString($q)
    try {
        $res = Invoke-RestMethod -Uri $url -UserAgent "Mozilla/5.0"
        $valid = $res | Where-Object { $_.name -and $_.name -ne "No results returned" } | Select-Object -First 3
        foreach ($item in $valid) {
            $sizeGB = [Math]::Round([double]$item.size / (1024*1024*1024), 2)
            Write-Host "  -> Title: $($item.name)"
            Write-Host "     Size: $sizeGB GB | Seeds: $($item.seeders) | Hash: $($item.info_hash)"
        }
    } catch {
        Write-Host "Error querying $url : $_"
    }
}
