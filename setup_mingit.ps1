Write-Host "=== DESCARGANDO MINGIT PORTABLE PARA WINDOWS ===" -ForegroundColor Cyan

$zipPath = "$env:TEMP\MinGit.zip"
$destPath = "$env:LOCALAPPDATA\Programs\MinGit"

if (!(Test-Path "$destPath\cmd\git.exe")) {
    $url = "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/MinGit-2.48.1-64-bit.zip"
    Write-Host "[+] Descargando MinGit..."
    Invoke-WebRequest -Uri $url -OutFile $zipPath
    Write-Host "[+] Extrayendo en $destPath..."
    Expand-Archive -Path $zipPath -DestinationPath $destPath -Force
    Remove-Item $zipPath -Force
}

$env:PATH = "$destPath\cmd;$destPath\bin;$env:PATH"
& "$destPath\cmd\git.exe" --version
