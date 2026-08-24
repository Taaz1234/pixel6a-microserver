$apis = @(
    "https://yts.mx/api/v2/list_movies.json",
    "https://yts.bz/api/v2/list_movies.json",
    "https://yts.lt/api/v2/list_movies.json",
    "https://apibay.org/q.php?q=avatar",
    "https://torrents-csv.com/service/search?q=avatar"
)

foreach ($url in $apis) {
    try {
        $res = Invoke-RestMethod -Uri $url -TimeoutSec 3 -UserAgent "Mozilla/5.0"
        Write-Host "SUCCESS: $url"
    } catch {
        Write-Host "FAILED: $url ($($_.Exception.Message))"
    }
}
