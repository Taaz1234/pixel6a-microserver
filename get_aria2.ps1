$r = Invoke-RestMethod -Uri 'https://api.github.com/repos/P3TERX/Aria2-Pro-Core/releases/latest'
$asset = $r.assets | Where-Object { $_.name -like '*arm64*' -or $_.name -like '*aarch64*' -or $_.name -like '*arm-linux*' } | Select-Object -First 1
Write-Host "Found: $($asset.name)"
$outGz = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\$($asset.name)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $outGz

$destDir = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\aria2_bin"
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
tar -xzf $outGz -C $destDir
Write-Host "Extracted to $destDir!"
