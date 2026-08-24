$r = Invoke-RestMethod -Uri 'https://api.github.com/repos/bmax121/APatch/releases/latest'
$apk = $r.assets | Where-Object { $_.name -like '*.apk' } | Select-Object -First 1
Write-Host "Downloading $($apk.name) from $($apk.browser_download_url)..."
Invoke-WebRequest -Uri $apk.browser_download_url -OutFile "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\APatch.apk"
Write-Host "APatch downloaded successfully!"
