$movies = @("Gladiator", "Avatar", "Deadpool", "Oppenheimer", "The Batman")

foreach ($m in $movies) {
    $url = "https://en.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=" + [System.Uri]::EscapeDataString($m + " film") + "&gsrlimit=1&prop=pageimages&pithumbsize=600&format=json&origin=*"
    try {
        $res = Invoke-RestMethod -Uri $url -UserAgent "Mozilla/5.0"
        $pages = $res.query.pages
        foreach ($p in $pages.PSObject.Properties) {
            $img = $p.Value.thumbnail.source
            Write-Host "Movie: $m -> Poster: $img"
        }
    } catch {
        Write-Host "Error for $m : $_"
    }
}
