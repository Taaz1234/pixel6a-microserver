$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/dns_info" -Headers @{Authorization="Basic $base64"}

Write-Host "Blocking Mode:" $res.blocking_mode
Write-Host "Upstreams:" ($res.upstream_dns -join ', ')
Write-Host "Blocking IPv6:" $res.blocking_ipv6
