$config = @{
    web = @{
        ip = "0.0.0.0"
        port = 3000
    }
    dns = @{
        ip = "0.0.0.0"
        port = 53
    }
} | ConvertTo-Json

Write-Host "Configuring Web and DNS port 53..."
Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/install/configure" -Method Post -Body $config -ContentType "application/json"

Start-Sleep -Seconds 1

$user = @{
    name = "admin"
    password = "pixel6a123"
} | ConvertTo-Json

Write-Host "Setting admin credentials (admin / pixel6a123)..."
Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/install/set_password" -Method Post -Body $user -ContentType "application/json"

Write-Host "AdGuard Home initialized!"
