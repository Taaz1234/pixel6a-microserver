$payload = @{
    web = @{
        ip = "0.0.0.0"
        port = 3000
    }
    dns = @{
        ip = "0.0.0.0"
        port = 53
    }
    username = "admin"
    password = "pixel6a123"
} | ConvertTo-Json

Write-Host "Configuring AdGuard Home completely..."
$res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/install/configure" -Method Post -Body $payload -ContentType "application/json"
Write-Host "Response: $res"
