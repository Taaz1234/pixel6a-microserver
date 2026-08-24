$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== BLOQUEANDO BYPASS DOH (SECURE DNS) EN ADGUARD ===" -ForegroundColor Cyan

# Dominios DoH que usa Google Chrome para saltarse el DNS local
$dohBypassRules = @(
    "||dns.google^",
    "||dns.google.com^",
    "||cloudflare-dns.com^",
    "||chrome.cloudflare-dns.com^",
    "||one.one.one.one^",
    "||dns.quad9.net^",
    "||doh.opendns.com^",
    "||dns.adguard.com^",
    "||dns.nextdns.io^"
)

$currentRules = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/status" -Headers $headers
$rules = [System.Collections.Generic.HashSet[string]]::new()
foreach ($r in $currentRules.user_rules) {
    if (![string]::IsNullOrWhiteSpace($r)) {
        $rules.Add($r) | Out-Null
    }
}
foreach ($d in $dohBypassRules) {
    $rules.Add($d) | Out-Null
}

$body = @{
    rules = [string[]]$rules
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/filtering/set_rules" -Headers $headers -Method Post -Body $body -ContentType "application/json" | Out-Null
Write-Host "[+] Bloqueo de servidores DoH (Bypass de Chrome) activado con éxito en AdGuard." -ForegroundColor Green
