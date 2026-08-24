$wc = New-Object System.Net.WebClient
$html = $wc.DownloadString("https://developers.google.com/android/images")
$matches = [regex]::Matches($html, 'https://dl\.google\.com/dl/android/aosp/bluejay-[a-zA-Z0-9\._-]+\.zip')
$urls = $matches | ForEach-Object { $_.Value } | Select-Object -Unique
$urls | Select-Object -Last 10
