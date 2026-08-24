$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:pixel6a123")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

# Habilitar filtro AdGuard DNS Filter
$body = @{
    url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
    name = "AdGuard DNS filter"
    enabled = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body '{"rules":["||doubleclick.net^","||googleads.g.doubleclick.net^","||adservice.google.com^","||pagead2.googlesyndication.com^"]}' -ContentType "application/json"

Write-Host "Rules added! Testing DNS resolution on port 53..."
Start-Sleep -Seconds 1
Resolve-DnsName -Name doubleclick.net -Server 192.168.1.135
