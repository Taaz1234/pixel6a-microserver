$url = "https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/linux-arm64-filebrowser.tar.gz"
$outGz = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\filebrowser.tar.gz"
$outTar = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\filebrowser.tar"
$destDir = "C:\Users\manol\.gemini\antigravity-ide\scratch\pixel6a-microserver\filebrowser_bin"

Write-Host "Downloading FileBrowser ARM64..."
Invoke-WebRequest -Uri $url -OutFile $outGz

Write-Host "Extracting..."
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
tar -xzf $outGz -C $destDir

Write-Host "Extraction completed!"
