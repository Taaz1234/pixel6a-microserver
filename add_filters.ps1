$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:pixel6a123")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

# 1. Hagezi Multi PRO (Bloqueo masivo internacional)
$list1 = @{
    name = "Hagezi Multi PRO (Bloqueo Total)"
    url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"
    enabled = $true
} | ConvertTo-Json

# 2. AdGuard Mobile Ads Filter
$list2 = @{
    name = "AdGuard Mobile Ads Filter"
    url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
    enabled = $true
} | ConvertTo-Json

# 3. EasyList Spanish
$list3 = @{
    name = "EasyList Spanish"
    url = "https://easylist-downloads.adblockplus.org/easylistspanish.txt"
    enabled = $true
} | ConvertTo-Json

Write-Host "Adding Hagezi Multi PRO..."
try { Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/add_url" -Headers $headers -Method Post -Body $list1 -ContentType "application/json" } catch { Write-Host $_ }

Write-Host "Adding AdGuard Mobile Ads..."
try { Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/add_url" -Headers $headers -Method Post -Body $list2 -ContentType "application/json" } catch { Write-Host $_ }

Write-Host "Adding EasyList Spanish..."
try { Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/add_url" -Headers $headers -Method Post -Body $list3 -ContentType "application/json" } catch { Write-Host $_ }

Write-Host "Updating and reloading all filters..."
Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/refresh" -Headers $headers -Method Post -Body '{"whitelist":false}' -ContentType "application/json"

Write-Host "All filters applied successfully!"
