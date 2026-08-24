Write-Host "=== SUBIENDO ARCHIVOS DE PIXELCINEMA V2 VIA API ===" -ForegroundColor Cyan

# 1. Login en FileBrowser
$authBody = @{
    username = "admin"
    password = "Paco3421"
} | ConvertTo-Json

try {
    $loginRes = Invoke-RestMethod -Uri "http://192.168.1.135:8090/api/login" -Method Post -Body $authBody -ContentType "application/json"
    $token = $loginRes
    Write-Host "[+] Login exitoso en FileBrowser! Token recibido." -ForegroundColor Green
    
    $headers = @{
        "X-Auth" = $token
    }

    # 2. Subir cinema_server.py a /sdcard/Media/cinema_server.py
    $serverContent = [System.IO.File]::ReadAllBytes((Resolve-Path "cinema\cinema_server.py"))
    Invoke-RestMethod -Uri "http://192.168.1.135:8090/api/resources/cinema_server.py" -Method Post -Headers $headers -Body $serverContent -ContentType "application/octet-stream" | Out-Null
    Write-Host "[+] cinema_server.py subido a /sdcard/Media/cinema_server.py" -ForegroundColor Green

    # 3. Subir index.html a /sdcard/Media/index.html
    $htmlContent = [System.IO.File]::ReadAllBytes((Resolve-Path "cinema\index.html"))
    Invoke-RestMethod -Uri "http://192.168.1.135:8090/api/resources/index.html" -Method Post -Headers $headers -Body $htmlContent -ContentType "application/octet-stream" | Out-Null
    Write-Host "[+] index.html subido a /sdcard/Media/index.html" -ForegroundColor Green

    # 4. Crear carpetas Peliculas y Series en /sdcard/Media
    try {
        Invoke-RestMethod -Uri "http://192.168.1.135:8090/api/resources/Peliculas/" -Method Post -Headers $headers | Out-Null
        Invoke-RestMethod -Uri "http://192.168.1.135:8090/api/resources/Series/" -Method Post -Headers $headers | Out-Null
        Write-Host "[+] Carpetas /sdcard/Media/Peliculas y /sdcard/Media/Series creadas." -ForegroundColor Green
    } catch {
        Write-Host "[*] Carpetas ya existentes."
    }

} catch {
    Write-Host "[-] Error: $_" -ForegroundColor Red
}
