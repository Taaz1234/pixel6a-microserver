try {
    $res = Resolve-DnsName -Name "smetrics.samsung.com" -Server 192.168.1.135 -ErrorAction Stop
    Write-Host "IP:" $res.IPAddress
} catch {
    Write-Host "DNS status:" $_
}
