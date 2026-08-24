$r = Invoke-RestMethod -Uri 'https://api.github.com/repos/badabing2005/PixelFlasher/releases/latest'
$exe = $r.assets | Where-Object { $_.name -like '*exe*' -or $_.name -like '*zip*' } | Select-Object -First 1
Write-Host "Downloading $($exe.name)..."
Invoke-WebRequest -Uri $exe.browser_download_url -OutFile "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\$($exe.name)"
Write-Host "Download completed!"
