$gitExe = "$env:LOCALAPPDATA\Programs\MinGit\cmd\git.exe"
if (!(Test-Path $gitExe)) {
    $gitExe = (Get-Command git.exe -ErrorAction SilentlyContinue).Path
}

if (!(Test-Path $gitExe)) {
    Write-Host "[-] git.exe no encontrado aún."
    exit 1
}

Write-Host "[+] Usando Git: $gitExe" -ForegroundColor Green
$env:PATH = "$env:LOCALAPPDATA\Programs\MinGit\cmd;$env:PATH"

& $gitExe config --global --add safe.directory "*"
& $gitExe config user.name "manol"
& $gitExe config user.email "manol@antigravity.ide"

Write-Host "=== ESTADO DE GIT ===" -ForegroundColor Cyan
& $gitExe status

Write-Host "`n=== REMOTOS DE GIT ===" -ForegroundColor Cyan
& $gitExe remote -v

Write-Host "`n=== RAMA ACTUAL ===" -ForegroundColor Cyan
& $gitExe branch -a

Write-Host "`n=== PREPARANDO COMMIT ===" -ForegroundColor Green
& $gitExe add -A
& $gitExe commit -m "feat: PixelCinema Pro v2 (series), AdGuard 87k rules, and PixelMMO RPG Purpur 1.21.4"

Write-Host "`n=== SUBIENDO CAMBIOS A GITHUB (GIT PUSH) ===" -ForegroundColor Green
& $gitExe push origin HEAD
