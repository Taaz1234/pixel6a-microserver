$url = "https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.37.0/aria2-1.37.0-aarch64-linux-gnu.tar.gz"
$outGz = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\aria2.tar.gz"
$destDir = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\aria2_bin"

Write-Host "Downloading Aria2 ARM64..."
Invoke-WebRequest -Uri $url -OutFile $outGz

Write-Host "Extracting..."
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
tar -xzf $outGz -C $destDir

Write-Host "Done!"
